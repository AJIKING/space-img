import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/data/prefs_pool_store.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/pool/photo_pool.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/sample_photos.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('未保存なら null', () async {
    expect(await PrefsPoolStore().load(PhotoCategory.nebula), isNull);
  });

  test('カテゴリ別に往復で復元できる', () async {
    final store = PrefsPoolStore();
    final ts = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    await store.save(
      PhotoCategory.mars,
      PhotoPool(
        photos: [samplePhoto('a', category: PhotoCategory.mars)],
        lastRefreshedAt: ts,
      ),
    );

    final loaded = await store.load(PhotoCategory.mars);

    expect(loaded!.length, 1);
    expect(loaded.lastRefreshedAt, ts);
    expect(loaded.photos.first.category, PhotoCategory.mars);
  });

  test('別カテゴリは独立している', () async {
    final store = PrefsPoolStore();
    await store.save(
      PhotoCategory.mars,
      PhotoPool(photos: [samplePhoto('a', category: PhotoCategory.mars)]),
    );

    expect(await store.load(PhotoCategory.galaxy), isNull);
    expect((await store.load(PhotoCategory.mars))!.length, 1);
  });

  test('壊れた JSON は null(初回扱い)', () async {
    SharedPreferences.setMockInitialValues({
      PrefsPoolStore.keyFor(PhotoCategory.nebula): 'not json',
    });
    expect(await PrefsPoolStore().load(PhotoCategory.nebula), isNull);
  });

  test('未知カテゴリの写真はスキップする', () async {
    SharedPreferences.setMockInitialValues({
      PrefsPoolStore.keyFor(PhotoCategory.nebula):
          '{"photos":[{"id":"a","title":"t","center":"C",'
          '"category":"unknowncat","imageRef":"r"}],'
          '"lastRefreshedAt":null}',
    });

    final loaded = await PrefsPoolStore().load(PhotoCategory.nebula);

    expect(loaded!.photos, isEmpty);
  });
}
