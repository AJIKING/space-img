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
