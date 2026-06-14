@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/ui/viewer/dock.dart';

import 'golden_setup.dart';

void main() {
  Dock dock({bool isSaved = false}) => Dock(
    isSaved: isSaved,
    onSave: () {},
    onCollection: () {},
    onWallpaper: () {},
    onCustomize: () {},
  );

  testWidgets('Dock(SAVE オフ)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      goldenApp(Align(alignment: Alignment.bottomCenter, child: dock())),
    );

    await expectLater(find.byType(Dock), matchesGoldenFile('goldens/dock.png'));
  }, skip: skipGoldens);

  testWidgets('Dock(SAVE オン)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      goldenApp(
        Align(alignment: Alignment.bottomCenter, child: dock(isSaved: true)),
      ),
    );

    await expectLater(
      find.byType(Dock),
      matchesGoldenFile('goldens/dock_saved.png'),
    );
  }, skip: skipGoldens);
}
