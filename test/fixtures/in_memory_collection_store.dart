import 'package:orbit/src/domain/collection/collection_store.dart';
import 'package:orbit/src/domain/photos/photo.dart';

/// インメモリの [CollectionStore] fake。保存内容と回数を検証できる。
class InMemoryCollectionStore implements CollectionStore {
  InMemoryCollectionStore([List<Photo>? initial]) : _saved = [...?initial];

  List<Photo> _saved;
  int saveCount = 0;

  List<Photo> get saved => List.unmodifiable(_saved);

  @override
  Future<List<Photo>> load() async => List.of(_saved);

  @override
  Future<void> save(List<Photo> favorites) async {
    _saved = List.of(favorites);
    saveCount++;
  }
}
