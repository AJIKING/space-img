import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/application/collection_controller.dart';
import 'src/application/pool_controller.dart';
import 'src/application/settings_controller.dart';
import 'src/application/viewer_controller.dart';
import 'src/core/clock.dart';
import 'src/data/file_image_store.dart';
import 'src/data/nasa_photo_source.dart';
import 'src/data/prefs_collection_store.dart';
import 'src/data/prefs_pool_store.dart';
import 'src/data/prefs_settings_store.dart';
import 'src/data/seed_photos.dart';
import 'src/domain/pool/image_cache_cleaner.dart';
import 'src/domain/pool/pool_refresher.dart';

/// 本番 composition root。差し替え境界に本番実装を詰める。
///
/// 起動シーケンス(docs/architecture.md「表示と通信の分離」/ ADR 0001):
///   1. 設定を読み、現在の観測テーマ(カテゴリ)を決める。
///   2. そのカテゴリの保存済みプールを読む(無ければ同梱シード)。
///   3. プールから 1 枚選んで表示する(ここまで通信なし・高速・オフライン可)。
///   4. 表示が出た後にバックグラウンドで補充する。24h 経っていなければ何もしない。
///      補充結果は store に保存され、次回起動で新しいプールとして表示される。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const clock = SystemClock();
  final poolStore = PrefsPoolStore();
  final imageStore = FileImageStore();
  final refresher = PoolRefresher(
    clock: clock,
    source: NasaPhotoSource(),
    store: poolStore,
    imageStore: imageStore,
  );

  // カスタマイズ設定を読み込む(無ければ既定値)。観測テーマもここに含まれる。
  final settings = SettingsController(store: PrefsSettingsStore());
  await settings.load();

  // お気に入りを読み込む。
  final collection = CollectionController(store: PrefsCollectionStore());
  await collection.load();

  final pool = PoolController(
    store: poolStore,
    refresher: refresher,
    seedPools: buildSeedPools(),
    initialCategory: settings.settings.category,
    cleaner: ImageCacheCleaner(store: poolStore, imageStore: imageStore),
  );

  // 表示に使うプールを確定(通信しない)。
  await pool.load();

  // 表示経路。プールからランダムな位置で始める。
  final viewer = ViewerController(pool: pool.pool, random: Random());
  runApp(
    OrbitApp(
      viewer: viewer,
      pool: pool,
      settings: settings,
      collection: collection,
      clock: clock,
    ),
  );

  // 起動後にバックグラウンドで現在カテゴリを補充(表示はもう出ている)。
  // 失敗しても無視する(ADR 0004)。
  unawaited(pool.refresh());
}
