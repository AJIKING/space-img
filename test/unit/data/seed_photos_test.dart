import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/data/seed_photos.dart';
import 'package:orbit/src/domain/photos/photo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('シードの assets 参照は実際にバンドルされている', () async {
    final assetRefs = kSeedPhotos
        .map((p) => p.imageRef)
        .where((r) => r.startsWith('assets/'));
    expect(assetRefs, isNotEmpty);

    for (final ref in assetRefs) {
      final data = await rootBundle.load(ref);
      expect(data.lengthInBytes, greaterThan(0), reason: ref);
    }
  });

  test('buildSeedPools はカテゴリ別に束ねる', () {
    final pools = buildSeedPools();
    expect(pools[PhotoCategory.nebula]!.length, 1);
    expect(pools[PhotoCategory.galaxy]!.length, 1);
    expect(pools[PhotoCategory.earth]!.length, 1);
    // シードの各写真は宣言済みカテゴリと一致する。
    for (final entry in pools.entries) {
      for (final photo in entry.value.photos) {
        expect(photo.category, entry.key);
      }
    }
  });
}
