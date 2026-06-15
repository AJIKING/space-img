import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/domain/settings/viewer_settings.dart';
import 'package:orbit/src/ui/viewer/hud_overlay.dart';

import '../../fixtures/sample_photos.dart';

void main() {
  final now = DateTime(2026, 6, 14, 9, 5);

  Future<void> pumpHud(
    WidgetTester tester, {
    required ViewerSettings settings,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HudOverlay(
            photo: samplePhoto('a'),
            index: 0,
            total: 3,
            settings: settings,
            now: now,
          ),
        ),
      ),
    );
  }

  testWidgets('既定では時計・写真情報・進捗が出る(テレメトリ/レチクルは非表示)', (tester) async {
    await pumpHud(tester, settings: const ViewerSettings());

    expect(find.byKey(const Key('hud-clock')), findsOneWidget);
    expect(find.text('09:05'), findsOneWidget);
    expect(find.byKey(const Key('hud-meta')), findsOneWidget);
    expect(find.byKey(const Key('hud-progress')), findsOneWidget);
    // 観測機器の装飾は既定で非表示。
    expect(find.byKey(const Key('hud-telemetry-left')), findsNothing);
    expect(find.byKey(const Key('hud-reticle')), findsNothing);
  });

  testWidgets('showClock=false で時計が消える', (tester) async {
    await pumpHud(tester, settings: const ViewerSettings(showClock: false));
    expect(find.byKey(const Key('hud-clock')), findsNothing);
  });

  testWidgets('showTelemetry=true でテレメトリが出る', (tester) async {
    await pumpHud(tester, settings: const ViewerSettings(showTelemetry: true));
    expect(find.byKey(const Key('hud-telemetry-left')), findsOneWidget);
    expect(find.byKey(const Key('hud-telemetry-right')), findsOneWidget);
  });

  testWidgets('showReticle=true でレチクルが出る', (tester) async {
    await pumpHud(tester, settings: const ViewerSettings(showReticle: true));
    expect(find.byKey(const Key('hud-reticle')), findsOneWidget);
  });

  testWidgets('showMeta=false で写真情報が消える', (tester) async {
    await pumpHud(tester, settings: const ViewerSettings(showMeta: false));
    expect(find.byKey(const Key('hud-meta')), findsNothing);
  });
}
