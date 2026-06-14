import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/data/prefs_collection_store.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/sample_photos.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('未保存なら空リスト', () async {
    expect(await PrefsCollectionStore().load(), isEmpty);
  });

  test('お気に入りを往復で復元できる(順序保持)', () async {
    final store = PrefsCollectionStore();
    await store.save([
      samplePhoto('a'),
      samplePhoto('b', category: PhotoCategory.mars),
    ]);

    final loaded = await store.load();

    expect(loaded.map((p) => p.id), ['a', 'b']);
    expect(loaded[1].category, PhotoCategory.mars);
  });

  test('壊れた JSON は空リスト', () async {
    SharedPreferences.setMockInitialValues({
      PrefsCollectionStore.storageKey: 'not json',
    });
    expect(await PrefsCollectionStore().load(), isEmpty);
  });
}
