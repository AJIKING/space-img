/// プールを補充すべきかを判定する(pure。実時間に依存しない)。
///
/// 「前回更新から [interval](既定 24h)以上経過、または未補充なら補充する」
/// という ADR 0001 の方針を表す。判定に使う現在時刻は呼び出し側が [Clock] から
/// 渡す。補充の実行(通信)は補充経路の責務で、ここは純粋な判定だけを持つ。
class RefreshPolicy {
  const RefreshPolicy({this.interval = const Duration(hours: 24)});

  /// 補充間隔。既定 24 時間。
  final Duration interval;

  /// [now] 時点で補充すべきか。
  ///
  /// - [lastRefreshedAt] が null(未補充)なら true。
  /// - 経過時間が [interval] 以上なら true(ちょうど境界は補充する)。
  bool shouldRefresh({required DateTime now, DateTime? lastRefreshedAt}) {
    if (lastRefreshedAt == null) return true;
    return now.difference(lastRefreshedAt) >= interval;
  }
}
