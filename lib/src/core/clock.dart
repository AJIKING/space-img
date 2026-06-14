/// 現在時刻を返す境界。テストでは固定・手動進行の fake に差し替える。
///
/// 補充間隔(24h)判定・時計表示・おやすみタイマーはすべてこの境界を通す。
/// `DateTime.now()` の直叩きは禁止(docs/architecture.md の依存ルール)。
abstract class Clock {
  DateTime now();
}

/// 本番実装。システム時刻を返す。
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
