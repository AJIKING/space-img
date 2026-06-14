import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/data/prefs_settings_store.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/settings/viewer_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('未保存なら null', () async {
    expect(await PrefsSettingsStore().load(), isNull);
  });

  test('全フィールドを往復で復元できる', () async {
    final store = PrefsSettingsStore();
    const settings = ViewerSettings(
      category: PhotoCategory.saturn,
      showClock: false,
      clockPosition: ClockPosition.bottom,
      clockSize: ClockSize.l,
      use24h: false,
      showTelemetry: true,
      showReticle: true,
      showMeta: false,
      autoAdvance: true,
      intervalSeconds: 30,
    );
    await store.save(settings);

    final loaded = (await store.load())!;

    expect(loaded.category, PhotoCategory.saturn);
    expect(loaded.showClock, isFalse);
    expect(loaded.clockPosition, ClockPosition.bottom);
    expect(loaded.clockSize, ClockSize.l);
    expect(loaded.use24h, isFalse);
    expect(loaded.showTelemetry, isTrue);
    expect(loaded.showReticle, isTrue);
    expect(loaded.showMeta, isFalse);
    expect(loaded.autoAdvance, isTrue);
    expect(loaded.intervalSeconds, 30);
  });

  test('壊れた JSON は null(既定値起動)', () async {
    SharedPreferences.setMockInitialValues({
      PrefsSettingsStore.storageKey: 'not json',
    });
    expect(await PrefsSettingsStore().load(), isNull);
  });

  test('欠落フィールドは既定値で埋める(前方互換)', () async {
    SharedPreferences.setMockInitialValues({
      PrefsSettingsStore.storageKey: '{"showClock":false}',
    });

    final loaded = (await PrefsSettingsStore().load())!;

    const d = ViewerSettings();
    expect(loaded.showClock, isFalse); // 保存値
    expect(loaded.use24h, d.use24h); // 欠落→既定
    expect(loaded.clockPosition, d.clockPosition);
    expect(loaded.intervalSeconds, d.intervalSeconds);
  });
}
