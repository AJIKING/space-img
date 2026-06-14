import '../collection/collection_store.dart';
import '../photos/photo.dart';
import 'image_store.dart';
import 'pool_store.dart';

/// 画像キャッシュの全カテゴリ横断クリーンアップ(pure。境界だけに依存)。
///
/// どのカテゴリのプールにも参照されず、**かつお気に入りでもない**キャッシュ画像を
/// 削除する。**未ロードのカテゴリも [PoolStore] から読み**、**お気に入りも
/// [CollectionStore] から読んで** keep 対象に含める。これにより、補充で
/// プールから外れた写真でも、お気に入りに入れていれば画像は消えない。
class ImageCacheCleaner {
  ImageCacheCleaner({
    required this.store,
    required this.imageStore,
    required this.collectionStore,
  });

  final PoolStore store;
  final ImageStore imageStore;
  final CollectionStore collectionStore;

  /// 全カテゴリのプール + お気に入りが参照する画像 id の和集合を残し、それ以外を削除する。
  Future<void> prune() async {
    final keep = <String>{};
    for (final category in PhotoCategory.values) {
      final pool = await store.load(category);
      if (pool != null) {
        keep.addAll(pool.photos.map((p) => p.id));
      }
    }
    // お気に入りはプールから外れても残す。
    keep.addAll((await collectionStore.load()).map((p) => p.id));

    await imageStore.retainOnly(keep);
  }
}
