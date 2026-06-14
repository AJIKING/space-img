import 'dart:math';

import '../photos/photo.dart';
import 'photo_pool.dart';

/// プールから 1 枚をランダムに選ぶ。起動時の表示はこれだけで決まる(通信しない)。
///
/// 乱数は [Random] を注入する。テストでは `Random(seed)` を渡して決定的にし、
/// 失敗時は seed をログに残して再現する(docs/test-plan.md)。
class RandomPhotoPicker {
  RandomPhotoPicker(this._random);

  final Random _random;

  /// プールから 1 枚返す。空プールなら null。
  Photo? pick(PhotoPool pool) {
    if (pool.isEmpty) return null;
    return pool.photos[_random.nextInt(pool.length)];
  }
}
