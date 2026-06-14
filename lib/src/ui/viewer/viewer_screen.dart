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
  }

  @override
  void dispose() {
    widget.settings.removeListener(_onSettingsChanged);
    _ticker?.cancel();
    _autoTimer?.cancel();
    super.dispose();
  }

  void _onSettingsChanged() {
    _applyAutoAdvance();
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Dock(
                      isSaved:
                          photo != null && widget.collection.isFavorite(photo),
                      onSave: () {
                        if (photo == null) return;
                        final wasSaved = widget.collection.isFavorite(photo);
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
                          );
                        }
                      },
                      onCustomize: () =>
                          showCustomizeSheet(context, widget.settings),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
