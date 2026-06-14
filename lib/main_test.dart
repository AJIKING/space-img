import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/application/collection_controller.dart';
import 'src/application/pool_controller.dart';
import 'src/application/settings_controller.dart';
import 'src/application/viewer_controller.dart';
import 'src/core/clock.dart';
import 'src/data/file_image_store.dart';
import 'src/data/prefs_collection_store.dart';
import 'src/data/prefs_pool_store.dart';
import 'src/data/prefs_settings_store.dart';
import 'src/data/seed_photos.dart';
import 'src/domain/photos/photo.dart';
import 'src/domain/photos/photo_source.dart';
import 'src/domain/pool/image_cache_cleaner.dart';
import 'src/domain/pool/pool_refresher.dart';

/// integration test / 手動確認用の composition root。
///
/// **通信しない**(常に候補ゼロを返す source)ので、必ず同梱シードのまま起動する。
/// 固定 seed の [Random] で表示位置も決定的。state を毎回まっさらにしたい場合は
/// 端末のアプリデータを消すか、prefs をクリアして起動する。
class _OfflinePhotoSource implements PhotoSource {
  const _OfflinePhotoSource();

  @override
  Future<List<RemotePhoto>> fetchCandidates(
    PhotoCategory category, {
    int limit = 24,
  }) async => const [];

  @override
  Future<Uint8List> download(String imageUrl) async =>
      throw const PhotoSourceException('offline (main_test)');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const clock = SystemClock();
  final poolStore = PrefsPoolStore();
  final imageStore = FileImageStore();
  final refresher = PoolRefresher(
    clock: clock,
    source: const _OfflinePhotoSource(),
    store: poolStore,
    imageStore: imageStore,
    random: Random(0),
  );

  final settings = SettingsController(store: PrefsSettingsStore());
  await settings.load();
  final collection = CollectionController(store: PrefsCollectionStore());
  await collection.load();

  final pool = PoolController(
    store: poolStore,
    refresher: refresher,
    seedPools: buildSeedPools(),
    initialCategory: settings.settings.category,
    cleaner: ImageCacheCleaner(store: poolStore, imageStore: imageStore),
  );
  await pool.load();

  final viewer = ViewerController(pool: pool.pool, random: Random(0));
  runApp(
    OrbitApp(
      viewer: viewer,
      pool: pool,
      settings: settings,
      collection: collection,
      clock: clock,
    ),
  );

  unawaited(pool.refresh());
}
