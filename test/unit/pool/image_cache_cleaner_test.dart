import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/pool/image_cache_cleaner.dart';
import 'package:orbit/src/domain/pool/photo_pool.dart';

import '../../fixtures/in_memory_image_store.dart';
import '../../fixtures/in_memory_pool_store.dart';
import '../../fixtures/sample_photos.dart';

void main() {
  test('どのカテゴリにも参照されない画像を削除する', () async {
    final store = InMemoryPoolStore({
      PhotoCategory.nebula: PhotoPool(
        photos: [samplePhoto('a'), samplePhoto('b')],
      ),
      PhotoCategory.galaxy: PhotoPool(
        photos: [samplePhoto('c', category: PhotoCategory.galaxy)],
      ),
    });
    final imageStore = InMemoryImageStore();
    for (final id in ['a', 'b', 'c', 'orphan']) {
      imageStore.data[id] = Uint8List(0);
    }

    await ImageCacheCleaner(store: store, imageStore: imageStore).prune();

    expect(imageStore.data.keys.toSet(), {'a', 'b', 'c'});
  });

  test('全カテゴリ空なら全画像を消す', () async {
    final imageStore = InMemoryImageStore();
    imageStore.data['x'] = Uint8List(0);

    await ImageCacheCleaner(
      store: InMemoryPoolStore(),
      imageStore: imageStore,
    ).prune();

    expect(imageStore.data, isEmpty);
  });

  test('未ロード(store のみ)のカテゴリの画像も守る(誤削除しない)', () async {
    final store = InMemoryPoolStore({
      PhotoCategory.mars: PhotoPool(
        photos: [samplePhoto('m', category: PhotoCategory.mars)],
      ),
    });
    final imageStore = InMemoryImageStore();
    imageStore.data['m'] = Uint8List(0);
    imageStore.data['orphan'] = Uint8List(0);

    await ImageCacheCleaner(store: store, imageStore: imageStore).prune();

    expect(imageStore.data.keys.toSet(), {'m'});
  });
}
