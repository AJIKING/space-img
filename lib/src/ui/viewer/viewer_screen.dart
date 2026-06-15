import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../application/collection_controller.dart';
import '../../application/pool_controller.dart';
import '../../application/settings_controller.dart';
import '../../application/viewer_controller.dart';
import '../../core/clock.dart';
import '../../domain/photos/photo.dart';
import '../../domain/platform/screen_wake.dart';
import '../../domain/platform/wallpaper_service.dart';
import '../collection/collection_sheet.dart';
import '../customize/customize_sheet.dart';
import '../theme/orbit_theme.dart';
import '../wallpaper/wallpaper_preview.dart';
import 'dock.dart';
import 'hud_overlay.dart';
import 'photo_layer.dart';
import 'scan_overlay.dart';

/// メイン画面。写真レイヤ・HUD・ドックを重ね、ジェスチャー・時計更新・
/// 自動スライドを司る。
///
/// 表示は [ViewerController] のプールからのみ行い、通信しない(ADR 0001)。
class ViewerScreen extends StatefulWidget {
  const ViewerScreen({
    super.key,
    required this.controller,
    required this.pool,
    required this.settings,
    required this.collection,
    required this.clock,
    required this.wallpaper,
    required this.screenWake,
  });

  final ViewerController controller;
  final PoolController pool;
  final SettingsController settings;
  final CollectionController collection;
  final Clock clock;
  final WallpaperService wallpaper;
  final ScreenWake screenWake;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  late DateTime _now = widget.clock.now();
  late PhotoCategory _appliedCategory;
  Timer? _ticker;
  Timer? _autoTimer;
  Timer? _dockTimer;

  /// ドック(下部ナビ)の可視状態。無操作が続くと自動的に隠れる。
  bool _dockVisible = true;
  static const Duration _dockIdle = Duration(seconds: 4);

  /// 横ドラッグの累積量(スワイプ判定用)。
  double _dragDx = 0;
  static const double _swipeThreshold = 40;

  @override
  void initState() {
    super.initState();
    _appliedCategory = widget.settings.settings.category;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = widget.clock.now());
    });
    widget.settings.addListener(_onSettingsChanged);
    _applyAutoAdvance();
    _applyScreenWake();
    _revealDock();
  }

  @override
  void dispose() {
    widget.settings.removeListener(_onSettingsChanged);
    _ticker?.cancel();
    _autoTimer?.cancel();
    _dockTimer?.cancel();
    // 画面常時オンを解除する(この画面を離れたら通常に戻す)。
    widget.screenWake.setEnabled(false);
    super.dispose();
  }

  /// ドックを表示し、無操作タイマーを張り直す(一定時間後に自動で隠す)。
  /// initState からも呼ぶが、_dockVisible の初期値が true のため setState は
  /// 走らない(build 前 setState 違反を避けるための前提。初期値を変えないこと)。
  void _revealDock() {
    _dockTimer?.cancel();
    if (!_dockVisible) setState(() => _dockVisible = true);
    _dockTimer = Timer(_dockIdle, () {
      if (mounted) setState(() => _dockVisible = false);
    });
  }

  /// 画面タップ。状況に応じて HUD トグル / ドック復帰を出し分ける。
  void _onTap() {
    final c = widget.controller;
    if (c.hudHidden) {
      // 全部隠れている → 全部表示 + ドックの計時開始。
      c.toggleHud();
      _revealDock();
    } else if (!_dockVisible) {
      // 時計/情報は出ているがドックだけ自動で隠れた → ドックだけ戻す。
      _revealDock();
    } else {
      // 全部表示中 → 没入(全部隠す)。
      _dockTimer?.cancel();
      setState(() => _dockVisible = false);
      c.toggleHud();
    }
  }

  void _onSettingsChanged() {
    _applyAutoAdvance();
    _applyScreenWake();
    final category = widget.settings.settings.category;
    if (category != _appliedCategory) {
      _appliedCategory = category;
      _switchCategory(category);
    }
  }

  /// 観測テーマ切替: そのカテゴリのローカルプールを即表示してから補充する。
  Future<void> _switchCategory(PhotoCategory category) async {
    await widget.pool.setCategory(category);
    if (!mounted) return;
    widget.controller.showPool(widget.pool.pool); // 切替は新規表示なのでランダム
    await widget.pool.refresh();
    // 補充後はまだ同じテーマを見ているときだけ、表示を維持しつつ反映する。
    if (!mounted || widget.settings.settings.category != category) return;
    widget.controller.adoptPool(widget.pool.pool);
  }

  void _applyAutoAdvance() {
    _autoTimer?.cancel();
    final s = widget.settings.settings;
    if (s.autoAdvance) {
      _autoTimer = Timer.periodic(
        Duration(seconds: s.intervalSeconds),
        (_) => widget.controller.next(),
      );
    }
  }

  void _applyScreenWake() {
    widget.screenWake.setEnabled(widget.settings.settings.keepAwake);
  }

  /// 空表示からの手動再取得。補充して、取れたら表示に反映する。
  Future<void> _retry() async {
    await widget.pool.refresh();
    if (!mounted) return;
    widget.controller.adoptPool(widget.pool.pool);
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final c = widget.controller;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.arrowDown:
        c.next();
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowUp:
        c.prev();
      case LogicalKeyboardKey.space:
        c.toggleHud();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          _onKey(event);
          return KeyEventResult.handled;
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            c,
            widget.settings,
            widget.collection,
            widget.pool,
          ]),
          builder: (context, _) {
            final photo = c.current;
            final s = widget.settings.settings;
            // ドックは「HUD 表示中」かつ「無操作で自動非表示になっていない」とき表示。
            final dockShown = !c.hudHidden && _dockVisible;
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  key: const Key('viewer-gesture'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _onTap,
                  onHorizontalDragStart: (_) => _dragDx = 0,
                  onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
                  onHorizontalDragEnd: (_) {
                    if (_dragDx <= -_swipeThreshold) {
                      c.next();
                    } else if (_dragDx >= _swipeThreshold) {
                      c.prev();
                    } else {
                      return;
                    }
                    // 没入中(HUD 非表示)はドックを出さない=無駄な計時を避ける。
                    if (!c.hudHidden) _revealDock();
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PhotoLayer(photo: photo),
                      ScanOverlay(trigger: photo?.id),
                      IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 450),
                          opacity: c.hudHidden ? 0 : 1,
                          child: HudOverlay(
                            photo: photo,
                            index: c.index,
                            total: c.total,
                            settings: s,
                            now: _now,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ドックは HUD と一緒に表示 / 非表示する(タップで両方トグル)。
                // 非表示中はポインタを通すので、ドック位置のタップで再表示できる。
                Align(
                  alignment: Alignment.bottomCenter,
                  child: IgnorePointer(
                    ignoring: !dockShown,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 450),
                      opacity: dockShown ? 1 : 0,
                      child: SafeArea(
                        child: Dock(
                          isSaved:
                              photo != null &&
                              widget.collection.isFavorite(photo),
                          onSave: () {
                            if (photo == null) return;
                            final wasSaved = widget.collection.isFavorite(
                              photo,
                            );
                            widget.collection.toggle(photo);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  wasSaved ? 'コレクションから外しました' : 'コレクションに保存しました',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          onCollection: () => showCollectionSheet(
                            context,
                            widget.collection,
                            widget.controller.showPhoto,
                          ),
                          onWallpaper: () {
                            if (photo != null) {
                              showWallpaperPreview(
                                context,
                                photo,
                                widget.clock.now(),
                                widget.wallpaper,
                              );
                            }
                          },
                          onCustomize: () =>
                              showCustomizeSheet(context, widget.settings),
                        ),
                      ),
                    ),
                  ),
                ),
                // 表示できる写真が無い(テーマ色だけ)ときは、中央で状態を明示する
                // (取得中=スピナー / 未取得・失敗=再取得ボタン)。
                if (photo == null)
                  Center(
                    child: _EmptyState(
                      refreshing: widget.pool.isRefreshing,
                      onRetry: _retry,
                    ),
                  )
                // 写真は出ているが背景で補充中のときは、上部に控えめなチップ。
                else if (widget.pool.isRefreshing)
                  const Align(
                    alignment: Alignment(0, -0.92),
                    child: SafeArea(child: _LoadingChip()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 取得中の控えめなチップ(スピナー + 「取得中…」)。
class _LoadingChip extends StatelessWidget {
  const _LoadingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('loading-indicator'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xCC0A0E1A),
        border: Border.all(color: OrbitColors.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(OrbitColors.amber),
            ),
          ),
          const SizedBox(width: 9),
          Text(
            '取得中…',
            style: OrbitText.mono.copyWith(
              fontSize: 11,
              color: OrbitColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// 表示できる写真が無いときの中央表示。取得中はスピナー、未取得・失敗は再取得。
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.refreshing, required this.onRetry});

  final bool refreshing;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (refreshing) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(OrbitColors.amber),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '宇宙を取得中…',
            style: OrbitText.mono.copyWith(
              fontSize: 13,
              color: OrbitColors.hud,
              letterSpacing: 1,
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off, color: OrbitColors.muted, size: 42),
        const SizedBox(height: 14),
        Text(
          'まだ写真がありません',
          style: OrbitText.display.copyWith(
            fontSize: 16,
            color: OrbitColors.hud,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '通信環境を確認して再取得してください',
          style: OrbitText.mono.copyWith(
            fontSize: 11,
            color: OrbitColors.muted,
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          key: const Key('empty-retry'),
          onPressed: onRetry,
          child: const Text('再取得', style: TextStyle(color: OrbitColors.hud)),
        ),
      ],
    );
  }
}
