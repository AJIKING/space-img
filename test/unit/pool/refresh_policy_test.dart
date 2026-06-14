import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/domain/pool/refresh_policy.dart';

import '../../fixtures/fake_clock.dart';

void main() {
  const policy = RefreshPolicy();
  final base = DateTime.utc(2026, 6, 14, 9);

  test('未補充(null)なら補充する', () {
    expect(policy.shouldRefresh(now: base, lastRefreshedAt: null), isTrue);
  });

  test('24h 未満なら補充しない', () {
    final last = base.subtract(const Duration(hours: 23, minutes: 59));
    expect(policy.shouldRefresh(now: base, lastRefreshedAt: last), isFalse);
  });

  test('ちょうど 24h は補充する(境界)', () {
    final last = base.subtract(const Duration(hours: 24));
    expect(policy.shouldRefresh(now: base, lastRefreshedAt: last), isTrue);
  });

  test('24h 超過は補充する', () {
    final last = base.subtract(const Duration(hours: 30));
    expect(policy.shouldRefresh(now: base, lastRefreshedAt: last), isTrue);
  });

  test('Clock を進めると判定が変わる', () {
    final clock = FakeClock(base);
    final last = base.subtract(const Duration(hours: 23));
    // 23h 経過 → まだ補充しない。
    expect(
      policy.shouldRefresh(now: clock.now(), lastRefreshedAt: last),
      isFalse,
    );
    // さらに 1h 進めて 24h ちょうど → 補充する。
    clock.advance(const Duration(hours: 1));
    expect(
      policy.shouldRefresh(now: clock.now(), lastRefreshedAt: last),
      isTrue,
    );
  });
}
