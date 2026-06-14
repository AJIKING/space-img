import '../photos/photo.dart';

/// 端末ローカルにキャッシュした写真のプール(immutable)。
///
/// 表示はこのプールからランダムに 1 枚選ぶだけで、通信しない(ADR 0001)。
/// [lastRefreshedAt] は最後に補充した時刻で、[RefreshPolicy] が 24h 判定に使う。
class PhotoPool {
  PhotoPool({required List<Photo> photos, this.lastRefreshedAt})
    : photos = List.unmodifiable(photos);

  /// 空のプール(初回起動。シードで埋める。ADR 0004)。
  PhotoPool.empty() : photos = const [], lastRefreshedAt = null;

  final List<Photo> photos;
  final DateTime? lastRefreshedAt;

  bool get isEmpty => photos.isEmpty;
  bool get isNotEmpty => photos.isNotEmpty;
  int get length => photos.length;
}
