import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/photos/photo_source.dart';
import 'package:orbit/src/domain/pool/photo_pool.dart';
import 'package:orbit/src/domain/pool/pool_refresher.dart';

import '../../fixtures/fake_clock.dart';
import '../../fixtures/fake_photo_source.dart';
import '../../fixtures/in_memory_image_store.dart';
import '../../fixtures/in_memory_pool_store.dart';
import '../../fixtures/sample_photos.dart';

void main() {
  final now = DateTime.utc(2026, 6, 14, 9);

  PoolRefresher build({
    required FakePhotoSource source,
    FakeClock? clock,
    InMemoryPoolStore? store,
    InMemoryImageStore? imageStore,
    int minSize = 1,
    int targetSize = 30,
  }) {
    return PoolRefresher(
      clock: clock ?? FakeClock(now),
      source: source,
      store: store ?? InMemoryPoolStore(),
      imageStore: imageStore ?? InMemoryImageStore(),
      minSize: minSize,
      targetSize: targetSize,
    );
  }

  test('24h 未満ならスキップして source を呼ばない', () async {
    final source = FakePhotoSource(candidates: [sampleRemote('a')]);
    final current = PhotoPool(
      photos: [samplePhoto('old')],
      lastRefreshedAt: now.subtract(const Duration(hours: 1)),
    );

    final r = await build(
      source: source,
    ).refreshIfNeeded(current, PhotoCategory.nebula);

    expect(r.status, RefreshStatus.skippedFresh);
    expect(r.pool, same(current));
    expect(source.fetchCount, 0);
  });

  test('24h 経過していれば取得・保存して入れ替える', () async {
    final source = FakePhotoSource(
      candidates: [sampleRemote('a'), sampleRemote('b')],
    );
    final store = InMemoryPoolStore();
    final imageStore = InMemoryImageStore();
    final current = PhotoPool(
      photos: [samplePhoto('old')],
      lastRefreshedAt: now.subtract(const Duration(hours: 25)),
    );

    final r = await build(
      source: source,
      store: store,
      imageStore: imageStore,
    ).refreshIfNeeded(current, PhotoCategory.galaxy);

    expect(r.status, RefreshStatus.refreshed);
    expect(r.didRefresh, isTrue);
    expect(r.pool.length, 2);
    expect(r.pool.lastRefreshedAt, now);
    expect(store.savedFor(PhotoCategory.galaxy)!.length, 2);
    expect(imageStore.data.keys, containsAll(<String>['a', 'b']));
    expect(source.requestedCategories, [PhotoCategory.galaxy]);
  });

  test('初回(lastRefreshedAt=null)は補充する', () async {
    final source = FakePhotoSource(candidates: [sampleRemote('a')]);

    final r = await build(
      source: source,
    ).refreshIfNeeded(PhotoPool.empty(), PhotoCategory.nebula);

    expect(r.status, RefreshStatus.refreshed);
    expect(r.pool.length, 1);
  });

  test('候補 0 件なら旧プール維持・保存しない', () async {
    final source = FakePhotoSource(candidates: const []);
    final store = InMemoryPoolStore();
    final current = PhotoPool(photos: [samplePhoto('old')]);

    final r = await build(
      source: source,
      store: store,
    ).refreshIfNeeded(current, PhotoCategory.nebula);

    expect(r.status, RefreshStatus.skippedNoCandidates);
    expect(r.pool, same(current));
    expect(store.saveCount, 0);
  });

  test('取得が例外なら failed・旧プール維持・保存しない', () async {
    final source = FakePhotoSource(throwOnFetch: true);
    final store = InMemoryPoolStore();
    final current = PhotoPool(photos: [samplePhoto('old')]);

    final r = await build(
      source: source,
      store: store,
    ).refreshIfNeeded(current, PhotoCategory.nebula);

    expect(r.status, RefreshStatus.failed);
    expect(r.pool, same(current));
    expect(r.error, isA<PhotoSourceException>());
    expect(store.saveCount, 0);
  });

  test('一部のダウンロード失敗は残りで成立する', () async {
    final source = FakePhotoSource(
      candidates: [sampleRemote('a'), sampleRemote('b'), sampleRemote('c')],
      failingDownloadUrls: {'https://img/b.jpg'},
    );

    final r = await build(
      source: source,
    ).refreshIfNeeded(PhotoPool.empty(), PhotoCategory.nebula);

    expect(r.status, RefreshStatus.refreshed);
    expect(r.pool.photos.map((p) => p.id), ['a', 'c']);
  });

  test('全ダウンロード失敗で minSize 未満なら旧プール維持', () async {
    final source = FakePhotoSource(
      candidates: [sampleRemote('a')],
      failingDownloadUrls: {'https://img/a.jpg'},
    );
    final store = InMemoryPoolStore();
    final current = PhotoPool(photos: [samplePhoto('old')]);

    final r = await build(
      source: source,
      store: store,
    ).refreshIfNeeded(current, PhotoCategory.nebula);

    expect(r.status, RefreshStatus.skippedTooFew);
    expect(r.pool, same(current));
    expect(store.saveCount, 0);
  });

  test('重複 id は 1 つに畳む', () async {
    final source = FakePhotoSource(
      candidates: [sampleRemote('a'), sampleRemote('a')],
    );

    final r = await build(
      source: source,
    ).refreshIfNeeded(PhotoPool.empty(), PhotoCategory.nebula);

    expect(r.pool.length, 1);
  });

  test('補充は取得したカテゴリのキーへ保存する', () async {
    final source = FakePhotoSource(candidates: [sampleRemote('a')]);
    final store = InMemoryPoolStore();

    await build(
      source: source,
      store: store,
    ).refreshIfNeeded(PhotoPool.empty(), PhotoCategory.mars);

    expect(store.savedFor(PhotoCategory.mars), isNotNull);
    expect(store.savedFor(PhotoCategory.nebula), isNull);
  });
}
