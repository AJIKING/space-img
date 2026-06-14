import '../domain/photos/photo.dart';
import '../domain/pool/photo_pool.dart';

/// 初回起動・オフライン用の同梱シード(ADR 0004)。
///
/// プールが空のときだけ使い、補充が成功したら通常プールに置き換わる。
/// 実装フェーズで `assets/seed/` にバンドル画像(NASA クレジット明記)を置き、
/// [Photo.imageRef] をそのアセットパスにする。現状はメタのみのプレースホルダ。
const List<Photo> kSeedPhotos = [
  Photo(
    id: 'seed-nebula-1',
    title: 'カリーナ星雲(宇宙の崖)',
    center: 'STScI',
    category: PhotoCategory.nebula,
    imageRef: 'assets/seed/nebula_1.jpg',
    date: 'BUNDLED',
  ),
  Photo(
    id: 'seed-galaxy-1',
    title: '渦巻銀河 M51',
    center: 'STScI',
    category: PhotoCategory.galaxy,
    imageRef: 'assets/seed/galaxy_1.jpg',
    date: 'BUNDLED',
  ),
  Photo(
    id: 'seed-earth-1',
    title: '軌道上から見た地球の夜明け',
    center: 'JSC',
    category: PhotoCategory.earth,
    imageRef: 'assets/seed/earth_1.jpg',
    date: 'BUNDLED',
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
