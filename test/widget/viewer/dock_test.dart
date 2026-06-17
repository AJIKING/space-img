import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/ui/viewer/dock.dart';

import '../../fixtures/localized_app.dart';

void main() {
  testWidgets('各ボタンのタップが対応する callback を呼ぶ', (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: Dock(
            onSave: () => tapped.add('save'),
            onCollection: () => tapped.add('collection'),
            onWallpaper: () => tapped.add('wallpaper'),
            onCustomize: () => tapped.add('customize'),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('dock-save')));
    await tester.tap(find.byKey(const Key('dock-saved')));
    await tester.tap(find.byKey(const Key('dock-wallpaper')));
    await tester.tap(find.byKey(const Key('dock-tune')));

    expect(tapped, ['save', 'collection', 'wallpaper', 'customize']);
  });

  testWidgets('4 つのラベルが出る', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: Dock(
            onSave: () {},
            onCollection: () {},
            onWallpaper: () {},
            onCustomize: () {},
          ),
        ),
      ),
    );

    expect(find.text('SAVE'), findsOneWidget);
    expect(find.text('SAVED'), findsOneWidget);
    expect(find.text('WALLPAPER'), findsOneWidget);
    expect(find.text('TUNE'), findsOneWidget);
  });
}
