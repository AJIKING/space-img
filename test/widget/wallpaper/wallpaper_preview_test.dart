import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/ui/wallpaper/wallpaper_preview.dart';

import '../../fixtures/fake_wallpaper_service.dart';
import '../../fixtures/sample_photos.dart';

void main() {
  Future<void> pump(WidgetTester tester, FakeWallpaperService service) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WallpaperPreview(
            photo: samplePhoto('a'),
            now: DateTime(2026, 6, 15, 9, 5),
            service: service,
          ),
        ),
      ),
    );
  }

  testWidgets('時刻と保存ボタンを表示する(iOS 相当=直接設定不可)', (tester) async {
    await pump(tester, FakeWallpaperService());

    expect(find.text('09:05'), findsOneWidget);
    expect(find.byKey(const Key('wallpaper-save')), findsOneWidget);
    expect(find.byKey(const Key('wallpaper-set')), findsNothing);
  });

  testWidgets('保存ボタンで saveToGallery を呼ぶ', (tester) async {
    final service = FakeWallpaperService();
    await pump(tester, service);

    await tester.tap(find.byKey(const Key('wallpaper-save')));
    await tester.pump();

    expect(service.saved.single.id, 'a');
  });

  testWidgets('保存失敗でも例外を投げず失敗トーストを出す', (tester) async {
    await pump(tester, FakeWallpaperService(failSave: true));

    await tester.tap(find.byKey(const Key('wallpaper-save')));
    await tester.pump();

    expect(find.text('保存に失敗しました'), findsOneWidget);
  });

  testWidgets('直接設定対応(Android 相当)では壁紙設定ボタンが出て呼ばれる', (tester) async {
    final service = FakeWallpaperService(supportsDirectSet: true);
    await pump(tester, service);

    expect(find.byKey(const Key('wallpaper-set')), findsOneWidget);

    await tester.tap(find.byKey(const Key('wallpaper-set')));
    await tester.pump();

    expect(service.setAsWall.single.id, 'a');
  });
}
