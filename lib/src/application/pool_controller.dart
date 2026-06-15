import 'package:flutter/foundation.dart';

import '../domain/photos/photo.dart';
import '../domain/pool/image_cache_cleaner.dart';
import '../domain/pool/photo_pool.dart';
import '../domain/pool/pool_refresher.dart';
import '../domain/pool/pool_store.dart';

/// プールの状態を**カテゴリ(観測テーマ)単位**で保持する補充経路のコントローラ。
///
/// 起動時に現在カテゴリのプールを読み([load])、テーマ切替で [setCategory]、
/// 起動後・切替後に [refresh] で補充を起動する。**表示経路はここを通さず [pool]
/// を読むだけ**にする(`PhotoSource` を表示から呼ばない。ADR 0001)。
class PoolController extends ChangeNotifier {
  PoolController({
    required this.store,
    required this.refresher,
    required this.seedPools,
    required PhotoCategory initialCategory,
    this.cleaner,
  }) : _category = initialCategory;

  final PoolStore store;
  final PoolRefresher refresher;
  final Map<PhotoCategory, PhotoPool> seedPools;

  /// 画像の全カテゴリ横断クリーンアップ(任意)。補充成功後に走らせる。
  final ImageCacheCleaner? cleaner;

  /// 読み込み済み / 補充済みのカテゴリ別プール。
  final Map<PhotoCategory, PhotoPool> _pools = {};
  final PhotoPool _empty = PhotoPool.empty();

  PhotoCategory _category;
  bool _isRefreshing = false;
  RefreshStatus? _lastStatus;

  /// 補充を直列化するチェーン(同時に複数の refresh を走らせない。
  /// 並走すると掃除(prune)が別カテゴリの補充中画像を消しうるため)。
  Future<void> _refreshChain = Future<void>.value();

  PhotoCategory get category => _category;
  bool get isRefreshing => _isRefreshing;
  RefreshStatus? get lastStatus => _lastStatus;

  /// 現在カテゴリのプール(読込済み → シード → 空 の優先順)。
  PhotoPool get pool => _pools[_category] ?? seedPools[_category] ?? _empty;

  /// 起動時: 現在カテゴリの保存済みプールを読む(無ければシード/空のまま)。
  Future<void> load() async {
    await _ensureLoaded(_category);
    notifyListeners();
  }

  /// 観測テーマを切り替える。未読込なら store から読み込む。
  Future<void> setCategory(PhotoCategory category) async {
    if (category == _category) return;
    _category = category;
    await _ensureLoaded(category);
    notifyListeners();
  }

  /// 現在カテゴリを必要なら補充する。失敗・スキップ時は現状維持。
  /// 直前の補充が走っていれば、それが終わってから順番に実行する。
  Future<void> refresh() {
    final chain = _refreshChain.then((_) => _doRefresh());
    // 失敗してもチェーンを止めない(次回の refresh が動けるように)。
    _refreshChain = chain.catchError((_) {});
    return chain;
  }

  Future<void> _doRefresh() async {
    // 開始時点のカテゴリとプールを固定する(以降の setCategory 割り込みで
    // target と現プールが食い違わないように)。
    final target = _category;
    final current = pool;

    // 補充不要なら進捗(isRefreshing)を立てずに即終了する(チップのちらつき防止)。
    if (!refresher.shouldRefresh(current)) {
      _lastStatus = RefreshStatus.skippedFresh;
      return;
    }

    _isRefreshing = true;
    notifyListeners();

    final result = await refresher.refreshIfNeeded(current, target);

    _pools[target] = result.pool;
    _lastStatus = result.status;

    // 補充で新しい画像が増えたら、孤立した古い画像を全カテゴリ横断で掃除する。
    // ベストエフォート(失敗しても補充結果は壊さない)。
    if (result.didRefresh && cleaner != null) {
      try {
        await cleaner!.prune();
      } catch (_) {
        // 掃除失敗は無視する。
      }
    }

    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> _ensureLoaded(PhotoCategory category) async {
    if (_pools.containsKey(category)) return;
    final loaded = await store.load(category);
    if (loaded != null && loaded.isNotEmpty) {
      _pools[category] = loaded;
    }
  }
}
