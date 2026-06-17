import '../../l10n/app_localizations.dart';
import '../domain/photos/photo.dart';

/// カテゴリのローカライズ名(観測テーマのチップ表示用)。ロケールに追従する。
String categoryName(AppLocalizations l10n, PhotoCategory category) =>
    switch (category) {
      PhotoCategory.nebula => l10n.categoryNebula,
      PhotoCategory.galaxy => l10n.categoryGalaxy,
      PhotoCategory.earth => l10n.categoryEarth,
      PhotoCategory.mars => l10n.categoryMars,
      PhotoCategory.moon => l10n.categoryMoon,
      PhotoCategory.jupiter => l10n.categoryJupiter,
      PhotoCategory.sun => l10n.categorySun,
      PhotoCategory.deepField => l10n.categoryDeepField,
      PhotoCategory.aurora => l10n.categoryAurora,
      PhotoCategory.saturn => l10n.categorySaturn,
    };

/// カテゴリの英字コード(チップ副題。言語非依存のコールサイン表記)。
const Map<PhotoCategory, String> categoryLabelsEn = {
  PhotoCategory.nebula: 'NEBULA',
  PhotoCategory.galaxy: 'GALAXY',
  PhotoCategory.earth: 'EARTH',
  PhotoCategory.mars: 'MARS',
  PhotoCategory.moon: 'LUNAR',
  PhotoCategory.jupiter: 'JOVIAN',
  PhotoCategory.sun: 'SOLAR',
  PhotoCategory.deepField: 'DEEP FIELD',
  PhotoCategory.aurora: 'AURORA',
  PhotoCategory.saturn: 'SATURN',
};
