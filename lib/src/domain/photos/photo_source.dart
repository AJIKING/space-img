import 'dart:typed_data';

import 'photo.dart';

/// NASA から取得した写真候補(まだローカルキャッシュしていない)。
///
/// [imageUrl] はダウンロード元。`download` で取得したバイナリを [ImageStore] に
/// 保存して初めて、表示で使う [Photo] になる。
class RemotePhoto {
  const RemotePhoto({
    required this.id,
    required this.title,
    required this.center,
    required this.category,
    required this.imageUrl,
    this.date,
  });

  final String id;
  final String title;
  final String center;
  final PhotoCategory category;
  final String imageUrl;
  final String? date;
}

/// 写真の供給元(NASA Images API)を表す境界。**通信はすべてこの裏に閉じる**。
///
/// 補充経路だけがこれを呼ぶ。表示経路からは呼ばない(ADR 0001)。
/// 失敗・タイムアウト・HTTP エラーは [PhotoSourceException] で表現する
/// (呼び出し側は握りつぶして旧プールを保持する。ADR 0004)。
abstract class PhotoSource {
  /// カテゴリの写真候補メタを取得する。最大 [limit] 件。
  Future<List<RemotePhoto>> fetchCandidates(
    PhotoCategory category, {
    int limit,
  });

  /// 画像バイナリをダウンロードする。
  Future<Uint8List> download(String imageUrl);
}

/// 写真供給元での失敗(通信不可・タイムアウト・HTTP エラー・パース不能)。
class PhotoSourceException implements Exception {
  const PhotoSourceException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'PhotoSourceException: $message';
}
