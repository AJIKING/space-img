import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/data/photo_codec.dart';

void main() {
  group('resolveCachedRef', () {
    test('絶対パスはファイル名を現在のキャッシュへ繋ぎ直す', () {
      expect(
        resolveCachedRef('/old/Containers/UUID/photo_pool/abc.img', '/new'),
        '/new/abc.img',
      );
    });

    test('Windows パスのファイル名も抽出できる', () {
      expect(
        resolveCachedRef(r'C:\app\photo_pool\abc.img', '/new'),
        '/new/abc.img',
      );
    });

    test('相対ファイル名も現在のキャッシュへ繋ぐ', () {
      expect(resolveCachedRef('abc.img', '/new'), '/new/abc.img');
    });

    test('アセット参照はそのまま', () {
      expect(
        resolveCachedRef('assets/seed/nebula_1.jpg', '/new'),
        'assets/seed/nebula_1.jpg',
      );
    });

    test('空文字はそのまま', () {
      expect(resolveCachedRef('', '/new'), '');
    });

    test('URL / data URI は再ベースしない', () {
      expect(
        resolveCachedRef('https://x/y/a.jpg', '/new'),
        'https://x/y/a.jpg',
      );
      expect(
        resolveCachedRef('data:image/png;base64,AAAA', '/new'),
        'data:image/png;base64,AAAA',
      );
    });
  });
}
