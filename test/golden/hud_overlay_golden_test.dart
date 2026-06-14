@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/domain/settings/viewer_settings.dart';
import 'package:orbit/src/ui/viewer/hud_overlay.dart';

import '../fixtures/sample_photos.dart';
import 'golden_setup.dart';

void main() {
  final now = DateTime(2026, 6, 15, 9, 5);

  testWidgets('HUD 既定(時計上・全要素表示)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      goldenApp(
        HudOverlay(
          photo: samplePhoto('a'),
          index: 0,
          total: 5,
          settings: const ViewerSettings(),
          now: now,
        ),
      ),
    );

    await expectLater(
      find.byType(HudOverlay),
      matchesGoldenFile('goldens/hud_default.png'),
    );
  }, skip: skipGoldens);

  testWidgets('HUD 時計中央・テレメトリ/レチクル非表示', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      goldenApp(
        HudOverlay(
          photo: samplePhoto('a'),
          index: 2,
          total: 5,
          settings: const ViewerSettings(
            clockPosition: ClockPosition.center,
            showTelemetry: false,
            showReticle: false,
          ),
          now: now,
        ),
      ),
    );

    await expectLater(
      find.byType(HudOverlay),
      matchesGoldenFile('goldens/hud_minimal.png'),
    );
  }, skip: skipGoldens);
}
