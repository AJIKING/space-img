import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/application/collection_controller.dart';
import 'package:orbit/src/application/pool_controller.dart';
import 'package:orbit/src/application/settings_controller.dart';
import 'package:orbit/src/application/viewer_controller.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/pool/photo_pool.dart';
import 'package:orbit/src/domain/pool/pool_refresher.dart';
import 'package:orbit/src/domain/settings/viewer_settings.dart';
import 'package:orbit/src/ui/viewer/viewer_screen.dart';

import '../../fixtures/fake_clock.dart';
import '../../fixtures/fake_photo_source.dart';
import '../../fixtures/fake_screen_wake.dart';
import '../../fixtures/fake_wallpaper_service.dart';
import '../../fixtures/in_memory_collection_store.dart';
import '../../fixtures/in_memory_image_store.dart';
import '../../fixtures/in_memory_pool_store.dart';
import '../../fixtures/in_memory_settings_store.dart';
import '../../fixtures/sample_photos.dart';

void main() {
  final clock = FakeClock(DateTime(2026, 6, 15, 9, 5));

  PoolController poolWith(
    Map<PhotoCategory, PhotoPool> seeds, {
    FakePhotoSource? source,
    PhotoCategory initial = PhotoCategory.nebula,
  }) {
    final store = InMemoryPoolStore();
    return PoolController(
      store: store,
      refresher: PoolRefresher(
        clock: clock,
        source: source ?? FakePhotoSource(),
        store: store,
        imageStore: InMemoryImageStore(),
        random: Random(0),
      ),
      seedPools: seeds,
      initialCategory: initial,
    );
  }

  SettingsController settingsOf([ViewerSettings? initial]) =>
      SettingsController(
        store: InMemorySettingsStore(),
        initial: initial ?? const ViewerSettings(),
      );

  CollectionController collectionOf() =>
      CollectionController(store: InMemoryCollectionStore());

  Future<void> pumpScreen(
    WidgetTester tester, {
    required ViewerController viewer,
    required PoolController pool,
    required SettingsController settings,
    required CollectionController collection,
    FakeScreenWake? screenWake,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ViewerScreen(
          controller: viewer,
          pool: pool,
          settings: settings,
          collection: collection,
          clock: clock,
          wallpaper: FakeWallpaperService(),
          screenWake: screenWake ?? FakeScreenWake(),
        ),
      ),
    );
  }

  Future<void> dispose(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  PoolController nebulaPool(List<String> ids) => poolWith({
    PhotoCategory.nebula: PhotoPool(photos: ids.map(samplePhoto).toList()),
  });

  testWidgets('起動時にプールの写真メタが表示される(通信なし)', (tester) async {
    final pool = nebulaPool(['a', 'b', 'c']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settingsOf(),
      collection: collectionOf(),
    );

    expect(find.text(viewer.current!.title), findsOneWidget);

    await dispose(tester);
  });

  testWidgets('タップで HUD とドックが一緒に隠れ、ドック位置タップで再表示', (tester) async {
    final pool = nebulaPool(['a']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    final collection = collectionOf();
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settingsOf(),
      collection: collection,
    );

    // タップで HUD / ドックを隠す。
    await tester.tap(find.byKey(const Key('viewer-gesture')));
    await tester.pump();
    expect(viewer.hudHidden, isTrue);

    // 非表示中はドックの SAVE は効かず、タップで再表示される。
    await tester.tap(find.byKey(const Key('dock-save')), warnIfMissed: false);
    await tester.pump();
    expect(collection.favorites, isEmpty);
    expect(viewer.hudHidden, isFalse);

    await dispose(tester);
  });

  testWidgets('左スワイプで次へ、右スワイプで前へ', (tester) async {
    final pool = nebulaPool(['a', 'b', 'c']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settingsOf(),
      collection: collectionOf(),
    );
    final start = viewer.index;

    await tester.drag(
      find.byKey(const Key('viewer-gesture')),
      const Offset(-300, 0),
    );
    await tester.pump();
    expect(viewer.index, (start + 1) % 3);

    await tester.drag(
      find.byKey(const Key('viewer-gesture')),
      const Offset(300, 0),
    );
    await tester.pump();
    expect(viewer.index, start);

    await dispose(tester);
  });

  testWidgets('タップで HUD の表示が切り替わる', (tester) async {
    final pool = nebulaPool(['a']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settingsOf(),
      collection: collectionOf(),
    );
    expect(viewer.hudHidden, isFalse);

    await tester.tap(find.byKey(const Key('viewer-gesture')));
    await tester.pump();

    expect(viewer.hudHidden, isTrue);

    await dispose(tester);
  });

  testWidgets('設定変更が HUD にライブ反映される', (tester) async {
    final pool = nebulaPool(['a']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    final settings = settingsOf();
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settings,
      collection: collectionOf(),
    );
    expect(find.byKey(const Key('hud-meta')), findsOneWidget);

    await settings.update(settings.settings.copyWith(showMeta: false));
    await tester.pump();

    expect(find.byKey(const Key('hud-meta')), findsNothing);

    await dispose(tester);
  });

  testWidgets('自動スライド ON で間隔経過ごとに次へ進む', (tester) async {
    final pool = nebulaPool(['a', 'b', 'c']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    final settings = settingsOf(
      const ViewerSettings(autoAdvance: true, intervalSeconds: 6),
    );
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settings,
      collection: collectionOf(),
    );
    final start = viewer.index;

    await tester.pump(const Duration(seconds: 6));
    expect(viewer.index, (start + 1) % 3);

    await dispose(tester);
  });

  testWidgets('観測テーマを変えると表示プールが切り替わる', (tester) async {
    final pool = poolWith({
      PhotoCategory.nebula: PhotoPool(photos: [samplePhoto('n1')]),
      PhotoCategory.galaxy: PhotoPool(
        photos: [samplePhoto('g1', category: PhotoCategory.galaxy)],
      ),
    });
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    final settings = settingsOf();
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settings,
      collection: collectionOf(),
    );
    expect(find.text('title-n1'), findsOneWidget);

    await settings.update(
      settings.settings.copyWith(category: PhotoCategory.galaxy),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    expect(find.text('title-g1'), findsOneWidget);

    await dispose(tester);
  });

  testWidgets('SAVE タップで現在の写真をお気に入りに追加する', (tester) async {
    final pool = nebulaPool(['a']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    final collection = collectionOf();
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settingsOf(),
      collection: collection,
    );

    await tester.tap(find.byKey(const Key('dock-save')));
    await tester.pump();

    expect(collection.isFavorite(viewer.current!), isTrue);

    await dispose(tester);
  });

  testWidgets('SAVED タップでコレクションシートが開く', (tester) async {
    final pool = nebulaPool(['a']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settingsOf(),
      collection: collectionOf(),
    );

    await tester.tap(find.byKey(const Key('dock-saved')));
    await tester.pumpAndSettle();

    expect(find.text('コレクション'), findsOneWidget);

    await dispose(tester);
  });

  testWidgets('WALLPAPER タップで待ち受けプレビューが開く', (tester) async {
    final pool = nebulaPool(['a']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settingsOf(),
      collection: collectionOf(),
    );

    await tester.tap(find.byKey(const Key('dock-wallpaper')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('wallpaper-save')), findsOneWidget);

    await dispose(tester);
  });

  testWidgets('画面を常時オン設定で ScreenWake が有効になる', (tester) async {
    final pool = nebulaPool(['a']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    final settings = settingsOf();
    final screenWake = FakeScreenWake();
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settings,
      collection: collectionOf(),
      screenWake: screenWake,
    );
    // 既定(false)で起動。
    expect(screenWake.enabled, isFalse);

    await settings.update(settings.settings.copyWith(keepAwake: true));
    await tester.pump();
    expect(screenWake.enabled, isTrue);

    await dispose(tester);
    // 画面を離れたら解除される。
    expect(screenWake.enabled, isFalse);
  });

  testWidgets('TUNE タップでカスタマイズシートが開く', (tester) async {
    final pool = nebulaPool(['a']);
    final viewer = ViewerController(pool: pool.pool, random: Random(0));
    await pumpScreen(
      tester,
      viewer: viewer,
      pool: pool,
      settings: settingsOf(),
      collection: collectionOf(),
    );

    await tester.tap(find.byKey(const Key('dock-tune')));
    await tester.pumpAndSettle();

    expect(find.text('観測テーマ'), findsOneWidget);

    await dispose(tester);
  });
}
