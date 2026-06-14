import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/ui/viewer/photo_layer.dart';

void main() {
  test('空文字は null(画像なし)', () {
    expect(photoImageProvider(''), isNull);
  });

  test('assets/ 始まりはアセット画像', () {
    expect(photoImageProvider('assets/seed/nebula_1.jpg'), isA<AssetImage>());
  });

  test('それ以外はローカルファイル画像', () {
    final provider = photoImageProvider('/data/cache/photo_pool/abc.img');
    expect(provider, isA<FileImage>());
    expect(
      (provider! as FileImage).file.path,
      '/data/cache/photo_pool/abc.img',
    );
  });
}
