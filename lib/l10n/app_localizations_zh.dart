// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get tuneTitle => '自定义';

  @override
  String get sectionTheme => '观测主题';

  @override
  String get sectionClock => '时钟';

  @override
  String get sectionHud => 'HUD(观测仪表)';

  @override
  String get sectionAmbient => '氛围';

  @override
  String get clockShow => '显示时钟';

  @override
  String get clockPositionLabel => '位置';

  @override
  String get positionTop => '上';

  @override
  String get positionCenter => '居中';

  @override
  String get positionBottom => '下';

  @override
  String get clockSizeLabel => '大小';

  @override
  String get clock24h => '24小时制';

  @override
  String get hudTelemetry => '坐标遥测';

  @override
  String get hudReticle => '准星';

  @override
  String get hudMeta => '照片信息';

  @override
  String get autoAdvance => '自动切换';

  @override
  String get interval => '切换间隔';

  @override
  String get keepAwake => '屏幕常亮';

  @override
  String get keepAwakeSub => 'KEEP AWAKE — 凝望壁纸';

  @override
  String get collectionTitle => '收藏';

  @override
  String get collectionEmpty => '还没有保存的宇宙。\n在喜欢的照片上点击 ♡ SAVE\n即可记录在这里。';

  @override
  String get savedToCollection => '已保存到收藏';

  @override
  String get removedFromCollection => '已从收藏移除';

  @override
  String get loading => '加载中…';

  @override
  String get loadingSpace => '正在加载宇宙…';

  @override
  String get emptyTitle => '还没有照片';

  @override
  String get emptyHint => '请检查网络后重新获取';

  @override
  String get retry => '重新获取';

  @override
  String get saveSuccess => '照片已保存';

  @override
  String get saveSuccessIos => '照片已保存。可在 设置 → 壁纸 中设为壁纸';

  @override
  String get saveFailed => '保存失败';

  @override
  String get wallpaperSetSuccess => '已设为壁纸';

  @override
  String get wallpaperSetFailed => '设置壁纸失败';

  @override
  String get wallpaperHintAndroid => '可设为壁纸，或保存为照片。';

  @override
  String get wallpaperHintIos => 'iOS 无法从应用内设置壁纸。\n请保存照片后，从 设置 → 壁纸 应用。';

  @override
  String get wallpaperSetButton => '设为壁纸';

  @override
  String get savePhotoButton => '保存照片';

  @override
  String get close => '关闭';

  @override
  String get semSave => '添加到收藏';

  @override
  String get semCollection => '打开收藏';

  @override
  String get semWallpaper => '壁纸预览';

  @override
  String get semTune => '自定义';

  @override
  String semCurrentTime(String clock) {
    return '当前时间 $clock';
  }

  @override
  String hudDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get categoryNebula => '星云';

  @override
  String get categoryGalaxy => '星系';

  @override
  String get categoryEarth => '地球';

  @override
  String get categoryMars => '火星';

  @override
  String get categoryMoon => '月球';

  @override
  String get categoryJupiter => '木星';

  @override
  String get categorySun => '太阳';

  @override
  String get categoryDeepField => '深空';

  @override
  String get categoryAurora => '极光';

  @override
  String get categorySaturn => '土星';
}
