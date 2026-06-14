import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/pool/photo_pool.dart';
import 'package:orbit/src/domain/pool/random_photo_picker.dart';

Photo _photo(String id) => Photo(
  id: id,
  title: id,
  center: 'X',
  category: PhotoCategory.nebula,
  imageRef: '$id.jpg',
);

void main() {
  test('空プールは null を返す', () {
    final picker = RandomPhotoPicker(Random(1));
    expect(picker.pick(PhotoPool.empty()), isNull);
  });

  test('1 枚プールはその 1 枚を返す', () {
    final picker = RandomPhotoPicker(Random(1));
    final pool = PhotoPool(photos: [_photo('a')]);
    expect(picker.pick(pool)!.id, 'a');
  });

  test('同じ seed は同じ選択を再現する', () {
    final pool = PhotoPool(
      photos: [_photo('a'), _photo('b'), _photo('c'), _photo('d')],
    );
    final first = RandomPhotoPicker(Random(42)).pick(pool)!.id;
    final second = RandomPhotoPicker(Random(42)).pick(pool)!.id;
    expect(first, second);
  });

  test('選ばれるのは常にプール内の写真', () {
    final pool = PhotoPool(photos: [_photo('a'), _photo('b'), _photo('c')]);
    final picker = RandomPhotoPicker(Random(7));
    for (var i = 0; i < 20; i++) {
      expect(pool.photos.contains(picker.pick(pool)), isTrue);
    }
  });
}
