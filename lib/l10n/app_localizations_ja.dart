// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get tuneTitle => 'カスタマイズ';

  @override
  String get sectionTheme => '観測テーマ';

  @override
  String get sectionClock => '時計';

  @override
  String get sectionHud => 'HUD(観測機器の表示)';

  @override
  String get sectionAmbient => 'アンビエント';

  @override
  String get clockShow => '時計を表示';

  @override
  String get clockPositionLabel => '位置';

  @override
  String get positionTop => '上';

  @override
  String get positionCenter => '中央';

  @override
  String get positionBottom => '下';

  @override
  String get clockSizeLabel => 'サイズ';

  @override
  String get clock24h => '24時間表示';

  @override
  String get hudTelemetry => '座標テレメトリ';

  @override
  String get hudReticle => 'レチクル(照準)';

  @override
  String get hudMeta => '写真情報';

  @override
  String get autoAdvance => '自動スライド';

  @override
  String get interval => '切替の間隔';

  @override
  String get keepAwake => '画面を常時オン';

  @override
  String get keepAwakeSub => 'KEEP AWAKE — 眺める待ち受け';

  @override
  String get collectionTitle => 'コレクション';

  @override
  String get collectionEmpty =>
      '保存した宇宙はまだありません。\n気に入った写真で ♡ SAVE を押すと\nここに記録されます。';

  @override
  String get savedToCollection => 'コレクションに保存しました';

  @override
  String get removedFromCollection => 'コレクションから外しました';

  @override
  String get loading => '取得中…';

  @override
  String get loadingSpace => '宇宙を取得中…';

  @override
  String get emptyTitle => 'まだ写真がありません';

  @override
  String get emptyHint => '通信環境を確認して再取得してください';

  @override
  String get retry => '再取得';

  @override
  String get saveSuccess => '写真を保存しました';

  @override
  String get saveSuccessIos => '写真を保存しました。設定 → 壁紙 から設定できます';

  @override
  String get saveFailed => '保存に失敗しました';

  @override
  String get wallpaperSetSuccess => '壁紙に設定しました';

  @override
  String get wallpaperSetFailed => '壁紙の設定に失敗しました';

  @override
  String get wallpaperHintAndroid => '壁紙に設定するか、写真として保存できます。';

  @override
  String get wallpaperHintIos =>
      'iOS ではアプリから壁紙を設定できません。\n写真を保存して、設定 → 壁紙 から適用してください。';

  @override
  String get wallpaperSetButton => '壁紙に設定する';

  @override
  String get savePhotoButton => '写真を保存';

  @override
  String get close => '閉じる';

  @override
  String get semSave => 'お気に入りに追加';

  @override
  String get semCollection => 'コレクションを開く';

  @override
  String get semWallpaper => '待ち受けプレビュー';

  @override
  String get semTune => 'カスタマイズ';

  @override
  String semCurrentTime(String clock) {
    return '現在時刻 $clock';
  }

  @override
  String hudDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get categoryNebula => '星雲';

  @override
  String get categoryGalaxy => '銀河';

  @override
  String get categoryEarth => '地球';

  @override
  String get categoryMars => '火星';

  @override
  String get categoryMoon => '月';

  @override
  String get categoryJupiter => '木星';

  @override
  String get categorySun => '太陽';

  @override
  String get categoryDeepField => '深宇宙';

  @override
  String get categoryAurora => 'オーロラ';

  @override
  String get categorySaturn => '土星';
}
