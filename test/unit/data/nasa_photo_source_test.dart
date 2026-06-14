import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:orbit/src/data/nasa_photo_source.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/photos/photo_source.dart';

Map<String, dynamic> _item(String id) => {
  'href': 'https://x/$id/collection.json',
  'data': [
    {'title': 'title-$id', 'nasa_id': id, 'center': 'C'},
  ],
  'links': [
    {'href': 'https://x/$id~thumb.jpg'},
  ],
};

String _search(List<String> ids) => jsonEncode({
  'collection': {'items': ids.map(_item).toList()},
});

void main() {
  test('検索 URL にクエリと media_type=image を付ける', () async {
    late Uri captured;
    final client = MockClient((req) async {
      captured = req.url;
      return http.Response(_search(const []), 200);
    });

    await NasaPhotoSource(client: client).fetchCandidates(PhotoCategory.mars);

    expect(captured.queryParameters['q'], 'mars surface');
    expect(captured.queryParameters['media_type'], 'image');
    expect(captured.queryParameters['page_size'], '100');
  });

  test('limit 件に切り詰める', () async {
    final client = MockClient(
      (req) async => http.Response(_search(['a', 'b', 'c']), 200),
    );

    final r = await NasaPhotoSource(
      client: client,
    ).fetchCandidates(PhotoCategory.nebula, limit: 2);

    expect(r.length, 2);
  });

  test('検索の HTTP エラーは PhotoSourceException', () async {
    final client = MockClient((req) async => http.Response('nope', 503));

    expect(
      () => NasaPhotoSource(client: client).fetchCandidates(PhotoCategory.sun),
      throwsA(isA<PhotoSourceException>()),
    );
  });

  test('download はバイト列を返す', () async {
    final client = MockClient(
      (req) async => http.Response.bytes([1, 2, 3], 200),
    );

    final bytes = await NasaPhotoSource(
      client: client,
    ).download('https://x/a.jpg');

    expect(bytes, [1, 2, 3]);
  });

  test('download の HTTP エラーは PhotoSourceException', () async {
    final client = MockClient((req) async => http.Response('', 404));

    expect(
      () => NasaPhotoSource(client: client).download('https://x/a.jpg'),
      throwsA(isA<PhotoSourceException>()),
    );
  });

  test('download で画像以外の Content-Type は弾く', () async {
    final client = MockClient(
      (req) async => http.Response(
        '<html>error</html>',
        200,
        headers: {'content-type': 'text/html'},
      ),
    );

    expect(
      () => NasaPhotoSource(client: client).download('https://x/a.jpg'),
      throwsA(isA<PhotoSourceException>()),
    );
  });
}
