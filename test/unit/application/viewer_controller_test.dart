import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/application/viewer_controller.dart';
import 'package:orbit/src/domain/pool/photo_pool.dart';

import '../../fixtures/sample_photos.dart';

void main() {
  PhotoPool poolOf(List<String> ids) =>
      PhotoPool(photos: ids.map(samplePhoto).toList());

  test('起動位置は seed で決まる(決定的)', () {
    final expected = Random(0).nextInt(4);
    final controller = ViewerController(
      pool: poolOf(['a', 'b', 'c', 'd']),
      random: Random(0),
    );
    expect(controller.index, expected);
    expect(controller.current!.id, ['a', 'b', 'c', 'd'][expected]);
    expect(controller.total, 4);
  });

  test('next は末尾の次で先頭に巡回する', () {
    final controller = ViewerController(
      pool: poolOf(['a', 'b', 'c']),
      random: Random(0),
    );
    final start = controller.index;
    controller.next();
    expect(controller.index, (start + 1) % 3);
  });

  test('prev は先頭の前で末尾に巡回する', () {
    final controller = ViewerController(
      pool: poolOf(['a', 'b', 'c']),
      random: Random(0),
    );
    final start = controller.index;
    controller.prev();
    expect(controller.index, (start - 1 + 3) % 3);
  });

  test('空プールでも安全(current=null・next/prev は無反応)', () {
    final controller = ViewerController(
      pool: PhotoPool.empty(),
      random: Random(0),
    );
    expect(controller.current, isNull);
    expect(controller.total, 0);
    controller.next();
    controller.prev();
    expect(controller.index, 0);
  });

  test('showPool で別プールに差し替え、その中の写真を出す', () {
    final controller = ViewerController(
      pool: poolOf(['a', 'b']),
      random: Random(0),
    );

    controller.showPool(poolOf(['x', 'y', 'z']));

    expect(controller.total, 3);
    expect(['x', 'y', 'z'].contains(controller.current!.id), isTrue);
  });

  test('showPool に空プールを渡しても安全', () {
    final controller = ViewerController(pool: poolOf(['a']), random: Random(0));

    controller.showPool(PhotoPool.empty());

    expect(controller.current, isNull);
    expect(controller.index, 0);
  });

  test('showPhoto: プール内ならその位置へジャンプする', () {
    final controller = ViewerController(
      pool: poolOf(['a', 'b', 'c']),
      random: Random(0),
    );

    controller.showPhoto(samplePhoto('c'));

    expect(controller.current!.id, 'c');
    expect(controller.total, 3); // 既存なので増えない
  });

  test('showPhoto: プールに無ければ先頭に差し込んで表示する', () {
    final controller = ViewerController(
      pool: poolOf(['a', 'b']),
      random: Random(0),
    );

    controller.showPhoto(samplePhoto('z'));

    expect(controller.current!.id, 'z');
    expect(controller.total, 3);
  });

  test('toggleHud で反転し通知する', () {
    final controller = ViewerController(pool: poolOf(['a']), random: Random(0));
    var notified = 0;
    controller.addListener(() => notified++);
    expect(controller.hudHidden, isFalse);
    controller.toggleHud();
    expect(controller.hudHidden, isTrue);
    controller.toggleHud();
    expect(controller.hudHidden, isFalse);
    expect(notified, 2);
  });
}
