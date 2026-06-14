import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/application/pool_controller.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/pool/image_cache_cleaner.dart';
import 'package:orbit/src/domain/pool/photo_pool.dart';
import 'package:orbit/src/domain/pool/pool_refresher.dart';

import '../../fixtures/fake_clock.dart';
import '../../fixtures/fake_photo_source.dart';
import '../../fixtures/in_memory_image_store.dart';
import '../../fixtures/in_memory_pool_store.dart';
import '../../fixtures/sample_photos.dart';

void main() {
  final now = DateTime.utc(2026, 6, 14, 9);

  PoolController build({
    required FakePhotoSource source,
    InMemoryPoolStore? store,
    InMemoryImageStore? imageStore,
    Map<PhotoCategory, PhotoPool>? seedPools,
    PhotoCategory initialCategory = PhotoCategory.nebula,
    bool withCleaner = false,
  }) {
    final s = store ?? InMemoryPoolStore();
    final img = imageStore ?? InMemoryImageStore();
    final refresher = PoolRefresher(
      clock: FakeClock(now),
      source: source,
      store: s,
      imageStore: img,
    );
    return PoolController(
      store: s,
      refresher: refresher,
      seedPools: seedPools ?? const {},
      initialCategory: initialCategory,
      cleaner: withCleaner
          ? ImageCacheCleaner(store: s, imageStore: img)
          : null,
    );
  }

  test('load: 現在カテゴリの保存済みプールを使う', () async {
    final store = InMemoryPoolStore({
      PhotoCategory.nebula: PhotoPool(photos: [samplePhoto('saved')]),
    });
    final controller = build(source: FakePhotoSource(), store: store);

    await controller.load();

    expect(controller.pool.photos.single.id, 'saved');
  });

  test('保存が無ければシードを使う', () async {
    final controller = build(
      source: FakePhotoSource(),
      seedPools: {
        PhotoCategory.nebula: PhotoPool(photos: [samplePhoto('seed')]),
      },
    );

    await controller.load();

    expect(controller.pool.photos.single.id, 'seed');
  });

  test('setCategory: テーマを切り替えてそのカテゴリのプールを出す', () async {
    final store = InMemoryPoolStore({
      PhotoCategory.galaxy: PhotoPool(
        photos: [samplePhoto('g1', category: PhotoCategory.galaxy)],
      ),
    });
    final controller = build(source: FakePhotoSource(), store: store);

    await controller.setCategory(PhotoCategory.galaxy);

    expect(controller.category, PhotoCategory.galaxy);
    expect(controller.pool.photos.single.id, 'g1');
  });

  test('未取得カテゴリへ切替えるとプールは空', () async {
    final controller = build(source: FakePhotoSource());

    await controller.setCategory(PhotoCategory.saturn);

    expect(controller.pool.isEmpty, isTrue);
  });

  test('refresh: 現在カテゴリだけを補充する', () async {
    final controller = build(
      source: FakePhotoSource(
        candidates: [sampleRemote('a'), sampleRemote('b')],
      ),
      initialCategory: PhotoCategory.mars,
    );

    await controller.refresh();

    expect(controller.lastStatus, RefreshStatus.refreshed);
    expect(controller.category, PhotoCategory.mars);
    expect(controller.pool.length, 2);
    expect(controller.isRefreshing, isFalse);
  });

  test('refresh 成功後に孤立画像を全カテゴリ横断で掃除する', () async {
    final store = InMemoryPoolStore({
      PhotoCategory.galaxy: PhotoPool(
        photos: [samplePhoto('g', category: PhotoCategory.galaxy)],
      ),
    });
    final imageStore = InMemoryImageStore();
    imageStore.data['g'] = Uint8List(0); // 別カテゴリの画像(守られる)
    imageStore.data['orphan'] = Uint8List(0); // どこにも参照されない
    final controller = build(
      source: FakePhotoSource(candidates: [sampleRemote('a')]),
      store: store,
      imageStore: imageStore,
      withCleaner: true,
    );

    await controller.refresh(); // nebula を補充

    expect(imageStore.data.keys, containsAll(<String>['a', 'g']));
    expect(imageStore.data.containsKey('orphan'), isFalse);
  });

  test('refresh: 失敗してもプールは保持する', () async {
    final controller = build(
      source: FakePhotoSource(throwOnFetch: true),
      seedPools: {
        PhotoCategory.nebula: PhotoPool(photos: [samplePhoto('seed')]),
      },
    );

    await controller.refresh();

    expect(controller.lastStatus, RefreshStatus.failed);
    expect(controller.pool.photos.single.id, 'seed');
  });
}
