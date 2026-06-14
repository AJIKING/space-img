import 'dart:math';

import '../../core/clock.dart';
import '../photos/photo.dart';
import '../photos/photo_source.dart';
import 'image_store.dart';
import 'photo_pool.dart';
import 'pool_store.dart';
import 'refresh_policy.dart';

/// 補充の結果区分。
enum RefreshStatus {
  /// 取得・保存して新しいプールに入れ替えた。
  refreshed,

  /// まだ 24h 経っていないので何もしなかった。
  skippedFresh,

  /// 候補が 0 件だった(旧プール維持)。
  skippedNoCandidates,

  /// 保存できた写真が下限に満たなかった(旧プール維持)。
  skippedTooFew,

  /// 取得が失敗した(オフライン等。旧プール維持)。
  failed,
}

/// 補充の結果。[pool] は「これを表示に使えばよい」プール(成功なら新、
/// それ以外は現状維持)。
class PoolRefreshResult {
  const PoolRefreshResult(this.pool, this.status, {this.error});

  final PhotoPool pool;
  final RefreshStatus status;
  final Object? error;

  bool get didRefresh => status == RefreshStatus.refreshed;
}

/// プール補充のオーケストレーション(pure。境界だけに依存し、Flutter を知らない)。
///
/// 「24h 判定 → 取得 → ダウンロード&保存 → 新プール保存」を行う。**どの失敗でも
/// 旧プールを壊さない**(ADR 0004)。成功時のみ [PoolStore] を更新し、
/// `lastRefreshedAt` を進めるので、失敗時は次回起動で再試行される。
class PoolRefresher {
  PoolRefresher({
    required this.clock,
    required this.source,
    required this.store,
    required this.imageStore,
    required this.random,
    this.policy = const RefreshPolicy(),
    this.targetSize = 24,
    this.minSize = 1,
    this.candidatePoolSize = 80,
  }) : assert(minSize >= 1, 'minSize は 1 以上'),
       assert(targetSize >= minSize, 'targetSize は minSize 以上'),
       assert(
         candidatePoolSize >= targetSize,
         'candidatePoolSize は targetSize 以上',
       );

  final Clock clock;
  final PhotoSource source;
  final PoolStore store;
  final ImageStore imageStore;

  /// 候補のシャッフルに使う乱数。本番は entropy、テストは seed 固定で決定的に。
  final Random random;
  final RefreshPolicy policy;

  /// プールに溜める枚数(= ダウンロードする枚数)。
  final int targetSize;
  final int minSize;

  /// NASA から取得する候補メタの上限。これをシャッフルして [targetSize] 枚を選ぶ。
  /// 関連度順の先頭だけに偏らせない(似た写真ばかりになるのを避ける)。
  final int candidatePoolSize;

  /// 必要なら補充する。補充不要・失敗時は [current] をそのまま返す。
  Future<PoolRefreshResult> refreshIfNeeded(
    PhotoPool current,
    PhotoCategory category,
  ) async {
    final now = clock.now();
    if (!policy.shouldRefresh(
      now: now,
      lastRefreshedAt: current.lastRefreshedAt,
    )) {
      return PoolRefreshResult(current, RefreshStatus.skippedFresh);
    }

    try {
      final candidates = await source.fetchCandidates(
        category,
        limit: candidatePoolSize,
      );
      if (candidates.isEmpty) {
        return PoolRefreshResult(current, RefreshStatus.skippedNoCandidates);
      }

      // 関連度順の先頭に偏らないようシャッフルしてから targetSize 枚を選ぶ。
      final shuffled = [...candidates]..shuffle(random);

      final photos = <Photo>[];
      final seen = <String>{};
      for (final c in shuffled) {
        if (photos.length >= targetSize) break;
        if (!seen.add(c.id)) continue; // 同一 id の重複は捨てる
        try {
          final bytes = await source.download(c.imageUrl);
          final ref = await imageStore.store(c.id, bytes);
          photos.add(
            Photo(
              id: c.id,
              title: c.title,
              center: c.center,
              category: c.category,
              imageRef: ref,
              date: c.date,
              sourceUrl: c.imageUrl,
            ),
          );
        } catch (_) {
          // この 1 枚だけ落とし(DL 失敗・保存失敗のどちらでも)、残りで続行する。
          continue;
        }
      }

      if (photos.length < minSize) {
        return PoolRefreshResult(current, RefreshStatus.skippedTooFew);
      }

      final newPool = PhotoPool(photos: photos, lastRefreshedAt: now);
      // 画像の追い出しは全カテゴリ横断でないと他カテゴリを誤削除するため、
      // ここでは行わない(ADR 0001。掃除は全カテゴリを束ねる層の責務)。
      await store.save(category, newPool);
      return PoolRefreshResult(newPool, RefreshStatus.refreshed);
    } catch (e) {
      // 背景処理は決して投げない。どの失敗でも旧プールを保持する(ADR 0004)。
      return PoolRefreshResult(current, RefreshStatus.failed, error: e);
    }
  }
}
