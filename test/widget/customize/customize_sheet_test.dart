import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/application/settings_controller.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/settings/viewer_settings.dart';
import 'package:orbit/src/ui/customize/customize_sheet.dart';

import '../../fixtures/in_memory_settings_store.dart';
import '../../fixtures/localized_app.dart';

void main() {
  Future<SettingsController> pumpSheet(WidgetTester tester) async {
    final controller = SettingsController(store: InMemorySettingsStore());
    await tester.pumpWidget(
      localizedApp(Scaffold(body: CustomizeSheet(controller: controller))),
    );
    return controller;
  }

  testWidgets('トグルで設定が反転し永続化される', (tester) async {
    final controller = await pumpSheet(tester);
    expect(controller.settings.showMeta, isTrue);

    final toggle = find.descendant(
      of: find.byKey(const Key('tune-meta')),
      matching: find.byType(Switch),
    );
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();

    expect(controller.settings.showMeta, isFalse);
  });

  testWidgets('セグメントで時計位置を変更できる', (tester) async {
    final controller = await pumpSheet(tester);
    expect(controller.settings.clockPosition, ClockPosition.top);

    await tester.ensureVisible(find.text('下'));
    await tester.tap(find.text('下'));
    await tester.pump();

    expect(controller.settings.clockPosition, ClockPosition.bottom);
  });

  testWidgets('セグメントで切替間隔を変更できる', (tester) async {
    final controller = await pumpSheet(tester);

    await tester.ensureVisible(find.text('30s'));
    await tester.tap(find.text('30s'));
    await tester.pump();

    expect(controller.settings.intervalSeconds, 30);
  });

  testWidgets('観測テーマのチップで category を変更できる', (tester) async {
    final controller = await pumpSheet(tester);
    expect(controller.settings.category, PhotoCategory.nebula);

    await tester.tap(find.byKey(const Key('theme-galaxy')));
    await tester.pump();

    expect(controller.settings.category, PhotoCategory.galaxy);
  });

  testWidgets('主要セクションの見出しが出る', (tester) async {
    await pumpSheet(tester);
    expect(find.text('観測テーマ'), findsOneWidget);
    expect(find.text('時計'), findsOneWidget);
    expect(find.text('HUD(観測機器の表示)'), findsOneWidget);
    expect(find.text('アンビエント'), findsOneWidget);
  });
}
