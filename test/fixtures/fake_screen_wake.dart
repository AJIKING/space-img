import 'package:orbit/src/domain/platform/screen_wake.dart';

/// [ScreenWake] fake。最後に渡された値と呼び出し回数を記録する。
class FakeScreenWake implements ScreenWake {
  bool? enabled;
  int calls = 0;

  @override
  Future<void> setEnabled(bool value) async {
    enabled = value;
    calls++;
  }
}
