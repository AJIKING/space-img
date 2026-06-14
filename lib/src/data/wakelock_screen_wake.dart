import 'package:wakelock_plus/wakelock_plus.dart';

import '../domain/platform/screen_wake.dart';

/// [ScreenWake] の本番実装(`wakelock_plus`)。
class WakelockScreenWake implements ScreenWake {
  const WakelockScreenWake();

  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } catch (_) {
      // 未対応プラットフォーム(desktop/web 等)では no-op。
    }
  }
}
