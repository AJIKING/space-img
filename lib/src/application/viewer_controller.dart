import 'dart:math';

import 'package:flutter/foundation.dart';

import '../domain/photos/photo.dart';
import '../domain/pool/photo_pool.dart';

/// 表示中の写真と HUD 表示状態を持つ、**表示経路**のコントローラ。
///
/// 起動時にプールからランダムな位置で始め、スワイプで前後に巡回する。
/// **`PhotoSource` を一切持たない**ので、表示中に通信は起きない(ADR 0001)。
/// プールの補充は別経路([PoolController])の責務。
class ViewerController extends ChangeNotifier {
  ViewerController({required PhotoPool pool, required Random random})
    : _random = random,
      _pool = pool,
      _index = pool.isEmpty ? 0 : random.nextInt(pool.length);

  final Random _random;
  PhotoPool _pool;
  int _index;
  bool _hudHidden = false;

  PhotoPool get pool => _pool;
  int get index => _index;
  int get total => _pool.length;
  bool get hudHidden => _hudHidden;

  /// 表示中の写真。プールが空なら null。index は防御的にクランプする。
  Photo? get current =>
      _pool.isEmpty ? null : _pool.photos[_index.clamp(0, _pool.length - 1)];

  /// 次の写真へ(末尾の次は先頭へ巡回)。
  void next() {
    if (_pool.isEmpty) return;
    _index = (_index + 1) % _pool.length;
    notifyListeners();
  }

  /// 前の写真へ(先頭の前は末尾へ巡回)。
  void prev() {
    if (_pool.isEmpty) return;
    _index = (_index - 1 + _pool.length) % _pool.length;
    notifyListeners();
  }

  /// HUD の表示 / 非表示を切り替える(タップ没入)。
  void toggleHud() {
    _hudHidden = !_hudHidden;
    notifyListeners();
  }

  /// 別のプールに差し替えて、ランダムな位置で表示し直す(観測テーマ切替など、
  /// ユーザー操作で「新しく見せる」とき)。
  void showPool(PhotoPool pool) {
    _pool = pool;
    _index = pool.isEmpty ? 0 : _random.nextInt(pool.length);
    notifyListeners();
  }

  /// 別のプールに差し替えるが、**いま見ている写真は可能なら維持**する
  /// (バックグラウンド補充の完了時など、表示を勝手に飛ばしたくないとき)。
  /// 現在の写真が新プールに無ければランダムな位置を選ぶ(シード→実写真の移行)。
  void adoptPool(PhotoPool pool) {
    final currentId = current?.id;
    _pool = pool;
    final keptIndex = currentId == null
        ? -1
        : pool.photos.indexWhere((p) => p.id == currentId);
    _index = keptIndex >= 0
        ? keptIndex
        : (pool.isEmpty ? 0 : _random.nextInt(pool.length));
    notifyListeners();
  }

  /// 特定の写真を表示する(コレクションから選択)。現在のプールに在ればそこへ
  /// ジャンプし、無ければ先頭に差し込んで表示する。
  void showPhoto(Photo photo) {
    final existing = _pool.photos.indexWhere((p) => p.id == photo.id);
    if (existing >= 0) {
      _index = existing;
    } else {
      _pool = PhotoPool(
        photos: [photo, ..._pool.photos],
        lastRefreshedAt: _pool.lastRefreshedAt,
      );
      _index = 0;
    }
    notifyListeners();
  }
}
