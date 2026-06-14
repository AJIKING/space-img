/// 表示用フォーマッタ(pure Dart。flutter に依存しないので unit test で守れる)。
library;

const List<String> _weekdayJa = ['日', '月', '火', '水', '木', '金', '土'];

/// 時計表示 "HH:mm"。[use24h] が false なら 12 時間表記(0時/12時は 12)。
String formatClock(DateTime t, {required bool use24h}) {
  var h = t.hour;
  if (!use24h) {
    h = h % 12;
    if (h == 0) h = 12;
  }
  final hh = h.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

/// 午前 / 午後("AM" / "PM")。
String meridiem(DateTime t) => t.hour < 12 ? 'AM' : 'PM';

/// 日付 "M月D日 (曜)"。
String formatDate(DateTime t) =>
    '${t.month}月${t.day}日 (${_weekdayJa[t.weekday % 7]})';

/// 3 桁ゼロ詰めのフレーム番号。
String formatFrame(int n) => n.toString().padLeft(3, '0');
