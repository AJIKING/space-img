import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/domain/photos/photo.dart';

void main() {
  test('等価性は id だけで判定する', () {
    const a1 = Photo(
      id: 'x',
      title: 'A',
      center: 'JPL',
      category: PhotoCategory.mars,
      imageRef: 'a.jpg',
    );
    const a2 = Photo(
      id: 'x',
      title: 'まったく別のタイトル',
      center: 'GSFC',
      category: PhotoCategory.moon,
      imageRef: 'b.jpg',
    );
    const b = Photo(
      id: 'y',
      title: 'A',
      center: 'JPL',
      category: PhotoCategory.mars,
      imageRef: 'a.jpg',
    );

    expect(a1, a2);
    expect(a1.hashCode, a2.hashCode);
    expect(a1, isNot(b));
  });

  test('Set でプールの重複(同一 id)を排除できる', () {
    const a1 = Photo(
      id: 'x',
      title: 'A',
      center: 'JPL',
      category: PhotoCategory.mars,
      imageRef: 'a.jpg',
    );
    const a2 = Photo(
      id: 'x',
      title: 'A(別取得)',
      center: 'JPL',
      category: PhotoCategory.mars,
      imageRef: 'a2.jpg',
    );

    expect({a1, a2}.length, 1);
  });
}
