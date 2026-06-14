import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/ui/wallpaper/wallpaper_preview.dart';

import '../../fixtures/sample_photos.dart';

void main() {
  testWidgets('写真プレビューと時刻・操作ボタンを表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WallpaperPreview(
            photo: samplePhoto('a'),
            now: DateTime(2026, 6, 15, 9, 5),
          ),
        ),
      ),
    );

    expect(find.text('09:05'), findsOneWidget);
    expect(find.byKey(const Key('wallpaper-apply')), findsOneWidget);
    expect(find.byKey(const Key('wallpaper-close')), findsOneWidget);
  });
}
