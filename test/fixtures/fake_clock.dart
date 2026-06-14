import 'package:orbit/src/core/clock.dart';

/// 固定・手動進行の [Clock] fake(test/fixtures の共有資産)。
///
/// 実時間に依存せず補充間隔・おやすみタイマー・自動スライドを検証するために使う。
class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  /// 時刻を任意の値に設定する。
  void set(DateTime value) => _now = value;

  /// 時刻を [d] だけ進める。
  void advance(Duration d) => _now = _now.add(d);
}
