import '../domain/photos/photo.dart';
import '../domain/pool/photo_pool.dart';

/// 初回起動・オフライン用の同梱シード(ADR 0004)。
///
/// プールが空のときだけ使い、補充が成功したら通常プールに置き換わる。
/// 画像は NASA Image and Video Library(パブリックドメイン)の実写真を
/// `assets/seed/` に同梱(id は実 nasa_id。クレジットは assets/seed/NOTICE.md)。
const List<Photo> kSeedPhotos = [
  Photo(
    id: 'PIA14417',
    title: 'ダンベル星雲(M27)',
    center: 'JPL',
    category: PhotoCategory.nebula,
    imageRef: 'assets/seed/nebula_1.jpg',
    date: '2011-08-10',
  ),
  Photo(
    id: 'PIA04921',
    title: 'アンドロメダ銀河(M31)',
    center: 'JPL',
    category: PhotoCategory.galaxy,
    imageRef: 'assets/seed/galaxy_1.jpg',
    date: '2003-12-10',
  ),
  Photo(
    id: 'sl4-143-4707',
    title: '地球軌道のスカイラブ',
    center: 'JSC',
    category: PhotoCategory.earth,
    imageRef: 'assets/seed/earth_1.jpg',
    date: '1974-02-08',
  ),
  Photo(
    id: 'PIA05445',
    title: '火星表面(オポチュニティ)',
    center: 'JPL',
    category: PhotoCategory.mars,
    imageRef: 'assets/seed/mars_1.jpg',
    date: '2004-02-25',
  ),
  Photo(
    id: 'PIA12235',
    title: '月の表側',
    center: 'JPL',
    category: PhotoCategory.moon,
    imageRef: 'assets/seed/moon_1.jpg',
    date: '2009-09-24',
  ),
  Photo(
    id: 'PIA01527',
    title: '木星の嵐',
    center: 'JPL',
    category: PhotoCategory.jupiter,
    imageRef: 'assets/seed/jupiter_1.jpg',
    date: '1999-06-22',
  ),
  Photo(
    id: 'PIA26681',
    title: '太陽(SDO)',
    center: 'JPL',
    category: PhotoCategory.sun,
    imageRef: 'assets/seed/sun_1.jpg',
    date: '2025-09-15',
  ),
  Photo(
    id: 'PIA12110',
    title: 'ハッブル・ディープフィールド',
    center: 'STScI',
    category: PhotoCategory.deepField,
    imageRef: 'assets/seed/deepfield_1.jpg',
    date: '1996-01-15',
  ),
  Photo(
    id: 'hubble-jupiter-auroras-28000029525',
    title: '木星のオーロラ(Hubble)',
    center: 'GSFC',
    category: PhotoCategory.aurora,
    imageRef: 'assets/seed/aurora_1.jpg',
    date: '2016-06-30',
  ),
  Photo(
    id: 'PIA06423',
    title: '土星',
    center: 'JPL',
    category: PhotoCategory.saturn,
    imageRef: 'assets/seed/saturn_1.jpg',
    date: '2004-08-19',
  ),
];

/// 同梱シードをカテゴリ別プールに束ねる。シードのないカテゴリは空のまま
/// (初回選択時に補充される。ADR 0004)。
Map<PhotoCategory, PhotoPool> buildSeedPools() {
  final byCategory = <PhotoCategory, List<Photo>>{};
  for (final photo in kSeedPhotos) {
    byCategory.putIfAbsent(photo.category, () => []).add(photo);
  }
  return {
    for (final entry in byCategory.entries)
      entry.key: PhotoPool(photos: entry.value),
  };
}
