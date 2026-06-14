import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orbit/src/app.dart';
import 'package:orbit/src/application/collection_controller.dart';
import 'package:orbit/src/application/pool_controller.dart';
import 'package:orbit/src/application/settings_controller.dart';
import 'package:orbit/src/application/viewer_controller.dart';
import 'package:orbit/src/data/seed_photos.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/pool/pool_refresher.dart';

import '../test/fixtures/fake_clock.dart';
import '../test/fixtures/fake_photo_source.dart';
import '../test/fixtures/in_memory_collection_store.dart';
import '../test/fixtures/in_memory_image_store.dart';
import '../test/fixtures/in_memory_pool_store.dart';
import '../test/fixtures/in_memory_settings_store.dart';

/// オフライン起動の smoke journey(docs/test-plan.md):
/// 起動 → シードプールから 1 枚表示(通信なし)→ スワイプ → お気に入り保存。
///
/// 端末 / エミュレータが必要(`flutter test integration_test -d <device>`)。
/// CI は `.github/workflows/integration.yml`(main push と手動実行)。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('オフライン起動 → 表示 → スワイプ → お気に入り', (tester) async {
    final clock = FakeClock(DateTime(2026, 6, 15, 9, 5));
    final poolStore = InMemoryPoolStore();
    final imageStore = InMemoryImageStore();
    // フェイク source は候補ゼロ = 補充なし。表示はシードのまま(通信しない)。
    final refresher = PoolRefresher(
      clock: clock,
      source: FakePhotoSource(),
      store: poolStore,
      imageStore: imageStore,
    );
    final pool = PoolController(
      store: poolStore,
      refresher: refresher,
      seedPools: buildSeedPools(),
      initialCategory: PhotoCategory.nebula,
    );
    await pool.load();

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
      ),
    );
    await tester.pump();

    // 起動して写真が出ている(オフライン・通信なし)。
    expect(find.text('ORBIT'), findsOneWidget);
    expect(viewer.current, isNotNull);

    // スワイプしても落ちない。
    await tester.drag(
      find.byKey(const Key('viewer-gesture')),
      const Offset(-300, 0),
    );
    await tester.pump();
    expect(viewer.current, isNotNull);

    // お気に入りに保存できる。
    await tester.tap(find.byKey(const Key('dock-save')));
    await tester.pump();
    expect(collection.favorites, isNotEmpty);

    // 周期タイマーを止める。
    await tester.pumpWidget(const SizedBox());
  });
}
