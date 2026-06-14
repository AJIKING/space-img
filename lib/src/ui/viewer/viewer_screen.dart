import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../application/collection_controller.dart';
import '../../application/pool_controller.dart';
import '../../application/settings_controller.dart';
import '../../application/viewer_controller.dart';
import '../../core/clock.dart';
import '../../domain/photos/photo.dart';
import '../collection/collection_sheet.dart';
import '../customize/customize_sheet.dart';
import '../theme/orbit_theme.dart';
import '../wallpaper/wallpaper_preview.dart';
import 'dock.dart';
import 'hud_overlay.dart';
import 'photo_layer.dart';
import 'scan_overlay.dart';

/// メイン画面。写真レイヤ・HUD・ドックを重ね、ジェスチャー・時計更新・
/// 自動スライド・おやすみタイマーを司る。
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
  });

  final ViewerController controller;
  final PoolController pool;
  final SettingsController settings;
  final CollectionController collection;
  final Clock clock;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  late DateTime _now = widget.clock.now();
  late PhotoCategory _appliedCategory;
  Timer? _ticker;
  Timer? _autoTimer;
  Timer? _sleepTimer;
  bool _dimmed = false;

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
    _applySleep();
  }

  @override
  void dispose() {
    widget.settings.removeListener(_onSettingsChanged);
    _ticker?.cancel();
    _autoTimer?.cancel();
    _sleepTimer?.cancel();
    super.dispose();
  }

  void _onSettingsChanged() {
    _applyAutoAdvance();
    _applySleep();
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
    widget.controller.showPool(widget.pool.pool);
    await widget.pool.refresh();
    if (!mounted || widget.settings.settings.category != category) return;
    widget.controller.showPool(widget.pool.pool);
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

  /// おやすみタイマー: [ViewerSettings.sleepMinutes] 後に画面を暗転させる。
  void _applySleep() {
    _sleepTimer?.cancel();
    final minutes = widget.settings.settings.sleepMinutes;
    if (minutes > 0 && !_dimmed) {
      _sleepTimer = Timer(
        Duration(minutes: minutes),
        () => setState(() => _dimmed = true),
      );
    }
  }

  void _wake() {
    setState(() => _dimmed = false);
    _applySleep(); // 再び計時を始める
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
          animation: Listenable.merge([c, widget.settings, widget.collection]),
          builder: (context, _) {
            final photo = c.current;
            final s = widget.settings.settings;
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  key: const Key('viewer-gesture'),
                  behavior: HitTestBehavior.opaque,
                  onTap: c.toggleHud,
                  onHorizontalDragStart: (_) => _dragDx = 0,
                  onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
                  onHorizontalDragEnd: (_) {
                    if (_dragDx <= -_swipeThreshold) {
                      c.next();
                    } else if (_dragDx >= _swipeThreshold) {
                      c.prev();
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PhotoLayer(
                        photo: photo,
                        kenBurns: s.kenBurns && s.autoAdvance,
                      ),
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Dock(
                      isSaved:
                          photo != null && widget.collection.isFavorite(photo),
                      onSave: () {
                        if (photo != null) widget.collection.toggle(photo);
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
                          );
                        }
                      },
                      onCustomize: () =>
                          showCustomizeSheet(context, widget.settings),
                    ),
                  ),
                ),
                if (_dimmed) _DimOverlay(onWake: _wake),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// おやすみ暗転オーバーレイ。タップで復帰する。
class _DimOverlay extends StatelessWidget {
  const _DimOverlay({required this.onWake});

  final VoidCallback onWake;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        key: const Key('sleep-dim'),
        behavior: HitTestBehavior.opaque,
        onTap: onWake,
        child: const ColoredBox(
          color: Color(0xF5000000),
          child: Center(
            child: Text(
              'SLEEP MODE\nタップで再起動',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: OrbitColors.muted,
                fontSize: 11,
                height: 2,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
