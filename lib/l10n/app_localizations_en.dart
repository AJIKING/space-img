// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tuneTitle => 'Customize';

  @override
  String get sectionTheme => 'Observation Theme';

  @override
  String get sectionClock => 'Clock';

  @override
  String get sectionHud => 'HUD (Instruments)';

  @override
  String get sectionAmbient => 'Ambient';

  @override
  String get clockShow => 'Show clock';

  @override
  String get clockPositionLabel => 'Position';

  @override
  String get positionTop => 'Top';

  @override
  String get positionCenter => 'Center';

  @override
  String get positionBottom => 'Bottom';

  @override
  String get clockSizeLabel => 'Size';

  @override
  String get clock24h => '24-hour format';

  @override
  String get hudTelemetry => 'Coordinate telemetry';

  @override
  String get hudReticle => 'Reticle';

  @override
  String get hudMeta => 'Photo info';

  @override
  String get autoAdvance => 'Auto advance';

  @override
  String get interval => 'Interval';

  @override
  String get keepAwake => 'Keep screen on';

  @override
  String get keepAwakeSub => 'KEEP AWAKE — ambient wallpaper';

  @override
  String get collectionTitle => 'Collection';

  @override
  String get collectionEmpty =>
      'Nothing saved yet.\nTap ♡ SAVE on a photo you like\nto record it here.';

  @override
  String get savedToCollection => 'Added to collection';

  @override
  String get removedFromCollection => 'Removed from collection';

  @override
  String get loading => 'Loading…';

  @override
  String get loadingSpace => 'Loading the cosmos…';

  @override
  String get emptyTitle => 'No photos yet';

  @override
  String get emptyHint => 'Check your connection and reload';

  @override
  String get retry => 'Reload';

  @override
  String get saveSuccess => 'Photo saved';

  @override
  String get saveSuccessIos => 'Photo saved. Set it from Settings → Wallpaper';

  @override
  String get saveFailed => 'Failed to save';

  @override
  String get wallpaperSetSuccess => 'Set as wallpaper';

  @override
  String get wallpaperSetFailed => 'Failed to set wallpaper';

  @override
  String get wallpaperHintAndroid => 'Set as wallpaper, or save as a photo.';

  @override
  String get wallpaperHintIos =>
      'iOS does not allow setting wallpaper from an app.\nSave the photo and apply it from Settings → Wallpaper.';

  @override
  String get wallpaperSetButton => 'Set as wallpaper';

  @override
  String get savePhotoButton => 'Save photo';

  @override
  String get close => 'Close';

  @override
  String get semSave => 'Add to favorites';

  @override
  String get semCollection => 'Open collection';

  @override
  String get semWallpaper => 'Wallpaper preview';

  @override
  String get semTune => 'Customize';

  @override
  String semCurrentTime(String clock) {
    return 'Current time $clock';
  }

  @override
  String hudDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get categoryNebula => 'Nebula';

  @override
  String get categoryGalaxy => 'Galaxy';

  @override
  String get categoryEarth => 'Earth';

  @override
  String get categoryMars => 'Mars';

  @override
  String get categoryMoon => 'Moon';

  @override
  String get categoryJupiter => 'Jupiter';

  @override
  String get categorySun => 'Sun';

  @override
  String get categoryDeepField => 'Deep Field';

  @override
  String get categoryAurora => 'Aurora';

  @override
  String get categorySaturn => 'Saturn';
}
