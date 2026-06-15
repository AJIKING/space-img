import 'package:flutter/material.dart';

import '../../domain/photos/photo.dart';
import '../../domain/settings/viewer_settings.dart';
import '../format.dart';
import '../theme/orbit_theme.dart';

/// HUD オーバーレイ(時計・テレメトリ・レチクル・写真メタ・進捗・ブラケット)。
///
/// 与えられた値だけから描画する純粋な表示ウィジェット。[now] を外から渡すので、
/// 実時間を使わず固定時刻で widget test できる。表示の ON/OFF は [settings]。
class HudOverlay extends StatelessWidget {
  const HudOverlay({
    super.key,
    required this.photo,
    required this.index,
    required this.total,
    required this.settings,
    required this.now,
  });

  final Photo? photo;
  final int index;
  final int total;
  final ViewerSettings settings;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final clock = formatClock(now, use24h: settings.use24h);
    return Stack(
      fit: StackFit.expand,
      children: [
        // レチクル(中央照準 + 四隅のコーナーブラケット)。既定では非表示。
        if (settings.showReticle) ...[
          const _Bracket(top: 70, left: 18),
          const _Bracket(top: 70, right: 18),
          const _Bracket(bottom: 190, left: 18),
          const _Bracket(bottom: 190, right: 18),
          const Align(key: Key('hud-reticle'), child: _Reticle()),
        ],

        // テレメトリ
        if (settings.showTelemetry) ...[
          Positioned(
            key: const Key('hud-telemetry-left'),
            left: 24,
            top: 0,
            bottom: 0,
            child: Center(child: _telemetryLeft()),
          ),
          Positioned(
            key: const Key('hud-telemetry-right'),
            right: 24,
            top: 0,
            bottom: 0,
            child: Center(child: _telemetryRight()),
          ),
        ],

        // 大きい時計 + 日付
        if (settings.showClock)
          Align(
            alignment: _clockAlignment(settings.clockPosition),
            child: Column(
              key: const Key('hud-clock'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: '現在時刻 $clock',
                  child: Text(
                    clock,
                    style: _mono(
                      _clockFontSize(settings.clockSize),
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatDate(now).toUpperCase(),
                  style: _display(13, color: OrbitColors.hud),
                ),
              ],
            ),
          ),

        // 写真メタ
        if (settings.showMeta && photo != null)
          Positioned(
            key: const Key('hud-meta'),
            left: 26,
            right: 26,
            // ドック(下部ナビ)と被らないよう十分上に置く。
            bottom: 156,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo!.category.name.toUpperCase(),
                  style: _mono(10, color: OrbitColors.amber),
                ),
                const SizedBox(height: 8),
                Text(
                  photo!.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _display(19, color: OrbitColors.hud),
                ),
                const SizedBox(height: 6),
                Text(
                  'NASA · ${photo!.center}'
                  '${photo!.date == null ? '' : ' · ${photo!.date}'}',
                  style: _mono(11, color: OrbitColors.muted),
                ),
              ],
            ),
          ),

        // 進捗ドット
        if (total > 0)
          Positioned(
            key: const Key('hud-progress'),
            left: 0,
            right: 0,
            bottom: 138,
            child: _Progress(index: index, total: total),
          ),
      ],
    );
  }

  Widget _telemetryLeft() {
    final ra =
        '${(6 + index % 18).toString().padLeft(2, '0')} '
        '${((index * 7) % 60).toString().padLeft(2, '0')} '
        '${((index * 13) % 60).toString().padLeft(2, '0')}';
    final dec =
        '${index.isEven ? '+' : '-'}'
        '${(10 + index * 3 % 70).toString().padLeft(2, '0')} '
        '${((index * 11) % 60).toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('RA $ra', style: _mono(9.5, color: OrbitColors.muted)),
        Text('DEC $dec', style: _mono(9.5, color: OrbitColors.muted)),
        Text('TRACKING', style: _mono(9.5, color: OrbitColors.amber)),
      ],
    );
  }

  Widget _telemetryRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${formatFrame(index + 1)}/${formatFrame(total)}',
          style: _mono(9.5, color: OrbitColors.muted),
        ),
        Text('MAG +6.4', style: _mono(9.5, color: OrbitColors.muted)),
        Text('EXP 30s', style: _mono(9.5, color: OrbitColors.muted)),
      ],
    );
  }
}

Alignment _clockAlignment(ClockPosition pos) => switch (pos) {
  ClockPosition.top => const Alignment(0, -0.62),
  ClockPosition.center => Alignment.center,
  ClockPosition.bottom => const Alignment(0, 0.45),
};

double _clockFontSize(ClockSize size) => switch (size) {
  ClockSize.s => 46,
  ClockSize.m => 62,
  ClockSize.l => 78,
};

TextStyle _mono(
  double size, {
  Color color = OrbitColors.hud,
  FontWeight? weight,
}) => OrbitText.mono.copyWith(fontSize: size, color: color, fontWeight: weight);

TextStyle _display(double size, {required Color color}) =>
    OrbitText.display.copyWith(fontSize: size, color: color);

class _Bracket extends StatelessWidget {
  const _Bracket({this.top, this.bottom, this.left, this.right});

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border(
            top: left != null && top != null
                ? const BorderSide(color: OrbitColors.lineStrong)
                : BorderSide.none,
          ),
        ),
        // 角の表現は簡略化(2 辺の枠)。
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: OrbitColors.lineStrong, width: 1.5),
        ),
      ),
    );
  }
}

class _Reticle extends StatelessWidget {
  const _Reticle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 1, color: OrbitColors.lineStrong),
          Container(height: 1, color: OrbitColors.lineStrong),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: OrbitColors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final n = total < 8 ? total : 8;
    final active = total == 0 ? 0 : (index / total * n).floor().clamp(0, n - 1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < n; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: i == active ? 18 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: i == active ? OrbitColors.amber : OrbitColors.lineStrong,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
