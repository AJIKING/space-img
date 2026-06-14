import '../photos/photo.dart';
import 'image_store.dart';
import 'pool_store.dart';

/// 画像キャッシュの全カテゴリ横断クリーンアップ(pure。境界だけに依存)。
///
/// どのカテゴリのプールにも参照されていないキャッシュ画像を削除する。
/// **未ロードのカテゴリも [PoolStore] から読んで keep 対象に含める**ことで、
/// 他カテゴリの画像を誤って消さない(ADR 0001。補充経路は単一カテゴリしか
/// 知らないため、この掃除は全カテゴリを束ねるこの層の責務)。
class ImageCacheCleaner {
  ImageCacheCleaner({required this.store, required this.imageStore});

  final PoolStore store;
  final ImageStore imageStore;

  /// 全カテゴリのプールが参照する画像 id の和集合を残し、それ以外を削除する。
  Future<void> prune() async {
    final keep = <String>{};
    for (final category in PhotoCategory.values) {
      final pool = await store.load(category);
      if (pool != null) {
        keep.addAll(pool.photos.map((p) => p.id));
      }
    }
    await imageStore.retainOnly(keep);
  }
}
