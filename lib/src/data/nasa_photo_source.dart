import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../domain/photos/photo.dart';
import '../domain/photos/photo_source.dart';
import 'nasa_response.dart';

/// [PhotoSource] の本番実装。NASA Image and Video Library を叩く(キー不要)。
///
/// 失敗・タイムアウト・HTTP エラー・パース不能はすべて [PhotoSourceException]
/// に正規化する(ADR 0003)。`http.Client` を注入できるので、テストでは
/// MockClient で決定的に検証する(実通信しない)。
class NasaPhotoSource implements PhotoSource {
  NasaPhotoSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 6),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  static const String _searchBase = 'https://images-api.nasa.gov/search';

  @override
  Future<List<RemotePhoto>> fetchCandidates(
    PhotoCategory category, {
    int limit = 24,
  }) async {
    final uri = Uri.parse(_searchBase).replace(
      queryParameters: {
        'q': nasaQuery(category),
        'media_type': 'image',
        // 1 ページに多めに取り、呼び出し側(PoolRefresher)が広い候補から
        // ランダムに選ぶ(似た写真ばかりにならないように)。NASA の上限は 100。
        'page_size': '100',
      },
    );
    try {
      final res = await _client.get(uri).timeout(timeout);
      if (res.statusCode != 200) {
        throw PhotoSourceException('search HTTP ${res.statusCode}');
      }
      final all = parseNasaSearch(res.body, category);
      return all.take(limit).toList();
    } on PhotoSourceException {
      rethrow;
    } catch (e) {
      throw PhotoSourceException('search failed', cause: e);
    }
  }

  @override
  Future<Uint8List> download(String imageUrl) async {
    try {
      final res = await _client.get(Uri.parse(imageUrl)).timeout(timeout);
      if (res.statusCode != 200) {
        throw PhotoSourceException('download HTTP ${res.statusCode}');
      }
      return res.bodyBytes;
    } on PhotoSourceException {
      rethrow;
    } catch (e) {
      throw PhotoSourceException('download failed', cause: e);
    }
  }
}
