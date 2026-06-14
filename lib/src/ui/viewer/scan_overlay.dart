import 'package:flutter/material.dart';

import '../theme/orbit_theme.dart';

/// 写真切替時の「再取得スキャン」演出。[trigger] が変わるたびに上から下へ
/// 一筋のラインが走る(プロトタイプの .scan 相当)。視覚的フレーバー。
class ScanOverlay extends StatefulWidget {
  const ScanOverlay({super.key, required this.trigger});

  /// 値が変わると 1 回スキャンを走らせる(写真の id など)。
  final Object? trigger;

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didUpdateWidget(covariant ScanOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.isAnimating) return const SizedBox.shrink();
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: _controller.value * constraints.maxHeight,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00F5A623),
                            OrbitColors.amber,
                            Color(0x00F5A623),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
