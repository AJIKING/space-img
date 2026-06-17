import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/ui/format.dart';

void main() {
  test('formatClock: 24h はゼロ詰め HH:mm', () {
    expect(formatClock(DateTime(2026, 6, 14, 9, 5), use24h: true), '09:05');
    expect(formatClock(DateTime(2026, 6, 14, 23, 59), use24h: true), '23:59');
  });

  test('formatClock: 12h は 0時/12時を 12 に、午後は 12 時間表記', () {
    expect(formatClock(DateTime(2026, 6, 14, 0, 0), use24h: false), '12:00');
    expect(formatClock(DateTime(2026, 6, 14, 13, 5), use24h: false), '01:05');
    expect(formatClock(DateTime(2026, 6, 14, 12, 30), use24h: false), '12:30');
  });

  test('meridiem', () {
    expect(meridiem(DateTime(2026, 6, 14, 11)), 'AM');
    expect(meridiem(DateTime(2026, 6, 14, 12)), 'PM');
  });

  // 日付のロケール依存表記は AppLocalizations.hudDate に移したため、ここでは
  // 検証しない(localizations_test.dart でロケール別に検証する)。

  test('formatFrame: 3 桁ゼロ詰め', () {
    expect(formatFrame(1), '001');
    expect(formatFrame(42), '042');
  });
}
