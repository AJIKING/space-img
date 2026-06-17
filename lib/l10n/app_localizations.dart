import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @tuneTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get tuneTitle;

  /// No description provided for @sectionTheme.
  ///
  /// In en, this message translates to:
  /// **'Observation Theme'**
  String get sectionTheme;

  /// No description provided for @sectionClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get sectionClock;

  /// No description provided for @sectionHud.
  ///
  /// In en, this message translates to:
  /// **'HUD (Instruments)'**
  String get sectionHud;

  /// No description provided for @sectionAmbient.
  ///
  /// In en, this message translates to:
  /// **'Ambient'**
  String get sectionAmbient;

  /// No description provided for @clockShow.
  ///
  /// In en, this message translates to:
  /// **'Show clock'**
  String get clockShow;

  /// No description provided for @clockPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get clockPositionLabel;

  /// No description provided for @positionTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get positionTop;

  /// No description provided for @positionCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get positionCenter;

  /// No description provided for @positionBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get positionBottom;

  /// No description provided for @clockSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get clockSizeLabel;

  /// No description provided for @clock24h.
  ///
  /// In en, this message translates to:
  /// **'24-hour format'**
  String get clock24h;

  /// No description provided for @hudTelemetry.
  ///
  /// In en, this message translates to:
  /// **'Coordinate telemetry'**
  String get hudTelemetry;

  /// No description provided for @hudReticle.
  ///
  /// In en, this message translates to:
  /// **'Reticle'**
  String get hudReticle;

  /// No description provided for @hudMeta.
  ///
  /// In en, this message translates to:
  /// **'Photo info'**
  String get hudMeta;

  /// No description provided for @autoAdvance.
  ///
  /// In en, this message translates to:
  /// **'Auto advance'**
  String get autoAdvance;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @keepAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepAwake;

  /// No description provided for @keepAwakeSub.
  ///
  /// In en, this message translates to:
  /// **'KEEP AWAKE — ambient wallpaper'**
  String get keepAwakeSub;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionTitle;

  /// No description provided for @collectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet.\nTap ♡ SAVE on a photo you like\nto record it here.'**
  String get collectionEmpty;

  /// No description provided for @savedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Added to collection'**
  String get savedToCollection;

  /// No description provided for @removedFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Removed from collection'**
  String get removedFromCollection;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @loadingSpace.
  ///
  /// In en, this message translates to:
  /// **'Loading the cosmos…'**
  String get loadingSpace;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get emptyTitle;

  /// No description provided for @emptyHint.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and reload'**
  String get emptyHint;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get retry;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo saved'**
  String get saveSuccess;

  /// No description provided for @saveSuccessIos.
  ///
  /// In en, this message translates to:
  /// **'Photo saved. Set it from Settings → Wallpaper'**
  String get saveSuccessIos;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get saveFailed;

  /// No description provided for @wallpaperSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Set as wallpaper'**
  String get wallpaperSetSuccess;

  /// No description provided for @wallpaperSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to set wallpaper'**
  String get wallpaperSetFailed;

  /// No description provided for @wallpaperHintAndroid.
  ///
  /// In en, this message translates to:
  /// **'Set as wallpaper, or save as a photo.'**
  String get wallpaperHintAndroid;

  /// No description provided for @wallpaperHintIos.
  ///
  /// In en, this message translates to:
  /// **'iOS does not allow setting wallpaper from an app.\nSave the photo and apply it from Settings → Wallpaper.'**
  String get wallpaperHintIos;

  /// No description provided for @wallpaperSetButton.
  ///
  /// In en, this message translates to:
  /// **'Set as wallpaper'**
  String get wallpaperSetButton;

  /// No description provided for @savePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Save photo'**
  String get savePhotoButton;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @semSave.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get semSave;

  /// No description provided for @semCollection.
  ///
  /// In en, this message translates to:
  /// **'Open collection'**
  String get semCollection;

  /// No description provided for @semWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper preview'**
  String get semWallpaper;

  /// No description provided for @semTune.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get semTune;

  /// No description provided for @semCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Current time {clock}'**
  String semCurrentTime(String clock);

  /// No description provided for @hudDate.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String hudDate(DateTime date);

  /// No description provided for @categoryNebula.
  ///
  /// In en, this message translates to:
  /// **'Nebula'**
  String get categoryNebula;

  /// No description provided for @categoryGalaxy.
  ///
  /// In en, this message translates to:
  /// **'Galaxy'**
  String get categoryGalaxy;

  /// No description provided for @categoryEarth.
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get categoryEarth;

  /// No description provided for @categoryMars.
  ///
  /// In en, this message translates to:
  /// **'Mars'**
  String get categoryMars;

  /// No description provided for @categoryMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get categoryMoon;

  /// No description provided for @categoryJupiter.
  ///
  /// In en, this message translates to:
  /// **'Jupiter'**
  String get categoryJupiter;

  /// No description provided for @categorySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get categorySun;

  /// No description provided for @categoryDeepField.
  ///
  /// In en, this message translates to:
  /// **'Deep Field'**
  String get categoryDeepField;

  /// No description provided for @categoryAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get categoryAurora;

  /// No description provided for @categorySaturn.
  ///
  /// In en, this message translates to:
  /// **'Saturn'**
  String get categorySaturn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
