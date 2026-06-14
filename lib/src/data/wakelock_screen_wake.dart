import 'package:wakelock_plus/wakelock_plus.dart';

import '../domain/platform/screen_wake.dart';

/// [ScreenWake] の本番実装(`wakelock_plus`)。
class WakelockScreenWake implements ScreenWake {
  const WakelockScreenWake();

  @override
  Future<void> setEnabled(bool enabled) => WakelockPlus.toggle(enable: enabled);
}
