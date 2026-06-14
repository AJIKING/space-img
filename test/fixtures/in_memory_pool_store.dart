import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/pool/photo_pool.dart';
import 'package:orbit/src/domain/pool/pool_store.dart';

/// インメモリの [PoolStore] fake。カテゴリ別に保持し、保存回数を記録する。
class InMemoryPoolStore implements PoolStore {
  InMemoryPoolStore([Map<PhotoCategory, PhotoPool>? initial])
    : _data = {...?initial};

  final Map<PhotoCategory, PhotoPool> _data;
  int saveCount = 0;

  PhotoPool? savedFor(PhotoCategory category) => _data[category];

  @override
  Future<PhotoPool?> load(PhotoCategory category) async => _data[category];

  @override
  Future<void> save(PhotoCategory category, PhotoPool pool) async {
    _data[category] = pool;
    saveCount++;
  }
}
