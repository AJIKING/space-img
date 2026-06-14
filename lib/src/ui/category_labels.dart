import '../domain/photos/photo.dart';

/// カテゴリの日本語名(観測テーマのチップ表示用。プロトタイプの ja に対応)。
const Map<PhotoCategory, String> categoryLabelsJa = {
  PhotoCategory.nebula: '星雲',
  PhotoCategory.galaxy: '銀河',
  PhotoCategory.earth: '地球',
  PhotoCategory.mars: '火星',
  PhotoCategory.moon: '月',
  PhotoCategory.jupiter: '木星',
  PhotoCategory.sun: '太陽',
  PhotoCategory.deepField: '深宇宙',
  PhotoCategory.aurora: 'オーロラ',
  PhotoCategory.saturn: '土星',
};

/// カテゴリの英字コード(チップ副題。プロトタイプの en に対応)。
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
