import 'package:flutter/material.dart';

import '../theme/orbit_theme.dart';
import 'toggle_row.dart';

/// セグメント 1 つの選択肢。
class SegmentedOption<T> {
  const SegmentedOption(this.value, this.label);
  final T value;
  final String label;
}

/// 設定行に並べる小さなセグメンテッドコントロール(プロトタイプの .seg 相当)。
class SegmentedRow<T> extends StatelessWidget {
  const SegmentedRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final T value;
  final List<SegmentedOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      title: title,
      subtitle: subtitle,
      trailing: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x0AFFFFFF),
          border: Border.all(color: OrbitColors.line),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final option in options) _segment(option)],
          ),
        ),
      ),
    );
  }

  Widget _segment(SegmentedOption<T> option) {
    final selected = option.value == value;
    return GestureDetector(
      onTap: () => onChanged(option.value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? OrbitColors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          option.label,
          style: OrbitText.mono.copyWith(
            fontSize: 11,
            color: selected ? const Color(0xFF0A0E1A) : OrbitColors.muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
