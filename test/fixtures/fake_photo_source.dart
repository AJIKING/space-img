import 'dart:convert';
import 'dart:typed_data';

import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/photos/photo_source.dart';

/// 設定可能な [PhotoSource] fake(成功 / 空 / 失敗 / 一部失敗を再現)。
///
/// 呼び出し回数を記録するので「表示経路で source が呼ばれない」検証にも使える。
class FakePhotoSource implements PhotoSource {
  FakePhotoSource({
    List<RemotePhoto>? candidates,
    Set<String>? failingDownloadUrls,
    this.throwOnFetch = false,
  }) : candidates = candidates ?? const [],
       failingDownloadUrls = failingDownloadUrls ?? const {};

  List<RemotePhoto> candidates;
  Set<String> failingDownloadUrls;
  bool throwOnFetch;

  int fetchCount = 0;
  int downloadCount = 0;
  final List<PhotoCategory> requestedCategories = [];

  @override
  Future<List<RemotePhoto>> fetchCandidates(
    PhotoCategory category, {
    int limit = 24,
  }) async {
    fetchCount++;
    requestedCategories.add(category);
    if (throwOnFetch) {
      throw const PhotoSourceException('fetch failed (fake)');
    }
    return candidates.take(limit).toList();
  }

  @override
  Future<Uint8List> download(String imageUrl) async {
    downloadCount++;
    if (failingDownloadUrls.contains(imageUrl)) {
      throw PhotoSourceException('download failed (fake): $imageUrl');
    }
    return Uint8List.fromList(utf8.encode('bytes:$imageUrl'));
  }
}
