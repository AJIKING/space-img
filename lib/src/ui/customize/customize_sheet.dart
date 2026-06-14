import 'package:flutter/material.dart';

import '../../application/settings_controller.dart';
import '../../domain/photos/photo.dart';
import '../../domain/settings/viewer_settings.dart';
import '../category_labels.dart';
import '../theme/orbit_theme.dart';
import '../widgets/segmented_control.dart';
import '../widgets/toggle_row.dart';

/// TUNE シート。[SettingsController] を読み書きする。変更は即座に反映 + 永続化。
///
/// 観測テーマ(カテゴリ→プール切替)は別タスク(プール経路に絡むため)。ここでは
/// 時計 / HUD / アンビエントの表示設定を扱う。
class CustomizeSheet extends StatelessWidget {
  const CustomizeSheet({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final s = controller.settings;
        void update(ViewerSettings next) => controller.update(next);

        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFF0A0E1A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                border: Border(top: BorderSide(color: OrbitColors.line)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _grab(),
                    Row(
                      children: [
                        const Text(
                          'カスタマイズ',
                          style: TextStyle(
                            color: OrbitColors.hud,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 9),
                        _tag('TUNE'),
                        const Spacer(),
                        IconButton(
                          key: const Key('tune-close'),
                          icon: const Icon(
                            Icons.close,
                            color: OrbitColors.muted,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _label('観測テーマ'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in PhotoCategory.values)
                          _ThemeChip(
                            category: c,
                            selected: s.category == c,
                            onTap: () => update(s.copyWith(category: c)),
                          ),
                      ],
                    ),

                    _label('時計'),
                    ToggleRow(
                      key: const Key('tune-clock'),
                      title: '時計を表示',
                      subtitle: 'CLOCK OVERLAY',
                      value: s.showClock,
                      onChanged: (v) => update(s.copyWith(showClock: v)),
                    ),
                    SegmentedRow<ClockPosition>(
                      title: '位置',
                      subtitle: 'POSITION',
                      value: s.clockPosition,
                      options: const [
                        SegmentedOption(ClockPosition.top, '上'),
                        SegmentedOption(ClockPosition.center, '中央'),
                        SegmentedOption(ClockPosition.bottom, '下'),
                      ],
                      onChanged: (v) => update(s.copyWith(clockPosition: v)),
                    ),
                    SegmentedRow<ClockSize>(
                      title: 'サイズ',
                      subtitle: 'SIZE',
                      value: s.clockSize,
                      options: const [
                        SegmentedOption(ClockSize.s, 'S'),
                        SegmentedOption(ClockSize.m, 'M'),
                        SegmentedOption(ClockSize.l, 'L'),
                      ],
                      onChanged: (v) => update(s.copyWith(clockSize: v)),
                    ),
                    ToggleRow(
                      key: const Key('tune-24h'),
                      title: '24時間表示',
                      subtitle: '24H FORMAT',
                      value: s.use24h,
                      onChanged: (v) => update(s.copyWith(use24h: v)),
                    ),

                    _label('HUD(観測機器の表示)'),
                    ToggleRow(
                      key: const Key('tune-telemetry'),
                      title: '座標テレメトリ',
                      subtitle: 'RA / DEC READOUT',
                      value: s.showTelemetry,
                      onChanged: (v) => update(s.copyWith(showTelemetry: v)),
                    ),
                    ToggleRow(
                      key: const Key('tune-reticle'),
                      title: 'レチクル(照準)',
                      subtitle: 'CENTER RETICLE',
                      value: s.showReticle,
                      onChanged: (v) => update(s.copyWith(showReticle: v)),
                    ),
                    ToggleRow(
                      key: const Key('tune-meta'),
                      title: '写真情報',
                      subtitle: 'PHOTO METADATA',
                      value: s.showMeta,
                      onChanged: (v) => update(s.copyWith(showMeta: v)),
                    ),

                    _label('アンビエント'),
                    ToggleRow(
                      key: const Key('tune-auto'),
                      title: '自動スライド',
                      subtitle: 'AUTO ADVANCE',
                      value: s.autoAdvance,
                      onChanged: (v) => update(s.copyWith(autoAdvance: v)),
                    ),
                    SegmentedRow<int>(
                      title: '切替の間隔',
                      subtitle: 'INTERVAL',
                      value: s.intervalSeconds,
                      options: const [
                        SegmentedOption(6, '6s'),
                        SegmentedOption(12, '12s'),
                        SegmentedOption(30, '30s'),
                      ],
                      onChanged: (v) => update(s.copyWith(intervalSeconds: v)),
                    ),
                    ToggleRow(
                      key: const Key('tune-keep-awake'),
                      title: '画面を常時オン',
                      subtitle: 'KEEP AWAKE — 眺める待ち受け',
                      value: s.keepAwake,
                      onChanged: (v) => update(s.copyWith(keepAwake: v)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _grab() => Center(
    child: Container(
      width: 38,
      height: 4,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: OrbitColors.lineStrong,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: OrbitColors.amber),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: OrbitText.mono.copyWith(fontSize: 9, color: OrbitColors.amber),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 4),
    child: Text(
      text,
      style: OrbitText.mono.copyWith(
        fontSize: 10,
        color: OrbitColors.muted,
        letterSpacing: 1.6,
      ),
    ),
  );
}

/// 観測テーマの選択チップ。
class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final PhotoCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('theme-${category.name}'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0x29F5A623) : const Color(0x0AFFFFFF),
          border: Border.all(
            color: selected ? OrbitColors.amber : OrbitColors.line,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              categoryLabelsJa[category] ?? category.name,
              style: TextStyle(
                color: selected ? Colors.white : OrbitColors.hud,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              categoryLabelsEn[category] ?? '',
              style: OrbitText.mono.copyWith(
                fontSize: 9,
                color: selected ? OrbitColors.amber : OrbitColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// TUNE シートをモーダルで開くヘルパー。
Future<void> showCustomizeSheet(
  BuildContext context,
  SettingsController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CustomizeSheet(controller: controller),
  );
}
