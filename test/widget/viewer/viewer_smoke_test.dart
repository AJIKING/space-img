import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/app.dart';
import 'package:orbit/src/application/collection_controller.dart';
import 'package:orbit/src/application/pool_controller.dart';
import 'package:orbit/src/application/settings_controller.dart';
import 'package:orbit/src/application/viewer_controller.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/pool/photo_pool.dart';
import 'package:orbit/src/domain/pool/pool_refresher.dart';

import '../../fixtures/fake_clock.dart';
import '../../fixtures/fake_photo_source.dart';
import '../../fixtures/fake_screen_wake.dart';
import '../../fixtures/fake_wallpaper_service.dart';
import '../../fixtures/in_memory_collection_store.dart';
import '../../fixtures/in_memory_image_store.dart';
import '../../fixtures/in_memory_pool_store.dart';
import '../../fixtures/in_memory_settings_store.dart';

void main() {
  testWidgets('OrbitApp が起動しプールの写真を表示する(通信なし)', (tester) async {
    final clock = FakeClock(DateTime(2026, 6, 14, 9, 5));
    final seed = PhotoPool(
      photos: const [
        Photo(
          id: 'a',
          title: 'カリーナ星雲',
          center: 'STScI',
          category: PhotoCategory.nebula,
          imageRef: 'a.jpg',
        ),
      ],
    );
    final store = InMemoryPoolStore();
    final pool = PoolController(
      store: store,
      refresher: PoolRefresher(
        clock: clock,
        source: FakePhotoSource(),
        store: store,
        imageStore: InMemoryImageStore(),
        random: Random(0),
      ),
      seedPools: {PhotoCategory.nebula: seed},
      initialCategory: PhotoCategory.nebula,
    );
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    final settings = SettingsController(store: InMemorySettingsStore());
    final collection = CollectionController(store: InMemoryCollectionStore());

    await tester.pumpWidget(
      OrbitApp(
        viewer: viewer,
        pool: pool,
        settings: settings,
        collection: collection,
        clock: clock,
        wallpaper: FakeWallpaperService(),
        screenWake: FakeScreenWake(),
      ),
    );

    expect(find.text('ORBIT'), findsOneWidget);
    expect(find.text('カリーナ星雲'), findsOneWidget);
    expect(find.text('NASA · STScI'), findsOneWidget);

    // 周期タイマーを止める。
    await tester.pumpWidget(const SizedBox());
  });
}
