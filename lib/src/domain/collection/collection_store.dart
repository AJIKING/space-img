import '../photos/photo.dart';

/// お気に入り(コレクション)の永続化境界。
abstract class CollectionStore {
  /// 保存済みのお気に入りを読む。未保存・壊れたデータなら空リスト。
  Future<List<Photo>> load();

  /// お気に入り一覧を保存する。
  Future<void> save(List<Photo> favorites);
}
