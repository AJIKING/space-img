import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/ui/viewer/photo_layer.dart';

void main() {
  testWidgets('imageRef があると Image を描画する', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PhotoLayer(
            photo: Photo(
              id: 'a',
              title: 't',
              center: 'C',
              category: PhotoCategory.nebula,
              imageRef: '/tmp/nope/a.img', // 実体は無い → グラデにフォールバック
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('imageRef が空ならグラデのみ(Image なし)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PhotoLayer(
            photo: Photo(
              id: 'a',
              title: 't',
              center: 'C',
              category: PhotoCategory.nebula,
              imageRef: '',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('photo が null でも落ちない(Image なし)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PhotoLayer(photo: null))),
    );

    expect(find.byType(Image), findsNothing);
  });
}
