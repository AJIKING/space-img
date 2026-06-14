import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/application/settings_controller.dart';
import 'package:orbit/src/domain/settings/viewer_settings.dart';

import '../../fixtures/in_memory_settings_store.dart';

void main() {
  test('load: 保存済み設定を適用する', () async {
    final store = InMemorySettingsStore(
      const ViewerSettings(showClock: false, clockSize: ClockSize.l),
    );
    final controller = SettingsController(store: store);

    await controller.load();

    expect(controller.settings.showClock, isFalse);
    expect(controller.settings.clockSize, ClockSize.l);
  });

  test('load: 保存が無ければ既定値のまま', () async {
    final controller = SettingsController(store: InMemorySettingsStore());

    await controller.load();

    expect(controller.settings.showClock, isTrue);
  });

  test('update: 通知して永続化する', () async {
    final store = InMemorySettingsStore();
    final controller = SettingsController(store: store);
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.update(
      controller.settings.copyWith(showMeta: false, intervalSeconds: 12),
    );

    expect(controller.settings.showMeta, isFalse);
    expect(controller.settings.intervalSeconds, 12);
    expect(notified, 1);
    expect(store.saveCount, 1);
    expect(store.saved!.showMeta, isFalse);
  });
}
