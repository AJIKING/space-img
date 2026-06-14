import 'dart:convert';

import '../domain/photos/photo.dart';
import '../domain/photos/photo_source.dart';

/// カテゴリ → NASA Images API の検索クエリ(プロトタイプの CATEGORIES 準拠)。
const Map<PhotoCategory, String> _queries = {
  PhotoCategory.nebula: 'nebula',
  PhotoCategory.galaxy: 'galaxy',
  PhotoCategory.earth: 'earth from space',
  PhotoCategory.mars: 'mars surface',
  PhotoCategory.moon: 'moon',
  PhotoCategory.jupiter: 'jupiter',
  PhotoCategory.sun: 'sun solar',
  PhotoCategory.deepField: 'hubble deep field',
  PhotoCategory.aurora: 'aurora',
  PhotoCategory.saturn: 'saturn',
};

/// 指定カテゴリの検索クエリ文字列。
String nasaQuery(PhotoCategory category) => _queries[category]!;

/// サムネイル URL をより大きい variant に昇格する(`~thumb.jpg` → `~medium.jpg`)。
/// プロトタイプ準拠で、`~orig` より到達性の高い `~medium` を使う。
String upgradeThumb(String thumb) => thumb.replaceFirst(
  RegExp(r'~thumb\.jpg$', caseSensitive: false),
  '~medium.jpg',
);

/// NASA Images API の検索レスポンス(JSON 文字列)を [RemotePhoto] のリストに
/// 変換する。**契約テストの対象**(`test/unit/data/nasa_response_test.dart`)。
///
/// - `links[0].href` と `data[0].title` を両方持つ item だけ採用する。
/// - 想定外のフィールド欠落の item はスキップし、例外にしない。
/// - JSON 自体が不正な場合は [PhotoSourceException] を投げる(呼び出し側で握る)。
List<RemotePhoto> parseNasaSearch(String body, PhotoCategory category) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw PhotoSourceException('invalid NASA JSON', cause: e);
  }

  if (decoded is! Map<String, dynamic>) return const [];
  final collection = decoded['collection'];
  if (collection is! Map<String, dynamic>) return const [];
  final items = collection['items'];
  if (items is! List) return const [];

  final result = <RemotePhoto>[];
  for (final item in items) {
    if (item is! Map<String, dynamic>) continue;

    final links = item['links'];
    final data = item['data'];
    if (links is! List || links.isEmpty) continue;
    if (data is! List || data.isEmpty) continue;

    final link0 = links.first;
    final data0 = data.first;
    if (link0 is! Map<String, dynamic> || data0 is! Map<String, dynamic>) {
      continue;
    }

    final href = link0['href'];
    final title = data0['title'];
    if (href is! String || href.isEmpty) continue;
    if (title is! String || title.isEmpty) continue;

    final nasaId = data0['nasa_id'];
    final center = data0['center'];
    final created = data0['date_created'];

    result.add(
      RemotePhoto(
        id: (nasaId is String && nasaId.isNotEmpty) ? nasaId : href,
        title: title,
        center: (center is String && center.isNotEmpty) ? center : 'NASA',
        category: category,
        imageUrl: upgradeThumb(href),
        date: (created is String && created.length >= 10)
            ? created.substring(0, 10)
            : null,
      ),
    );
  }
  return result;
}
