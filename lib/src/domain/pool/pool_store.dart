import '../photos/photo.dart';
import 'photo_pool.dart';

/// プール(写真リスト + lastRefreshedAt)の永続化境界。**カテゴリ単位**で読み書きする。
abstract class PoolStore {
  /// 指定カテゴリの保存済みプールを読む。未保存なら null。**壊れたデータでも
  /// 例外を投げず null** を返し、初回起動扱いにする(ADR 0004 / docs/test-plan.md)。
  Future<PhotoPool?> load(PhotoCategory category);

  /// 指定カテゴリのプールを保存する。
  Future<void> save(PhotoCategory category, PhotoPool pool);
}
