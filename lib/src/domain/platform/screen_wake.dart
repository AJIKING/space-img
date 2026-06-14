/// 画面スリープ防止のプラットフォーム境界(常時表示の“眺める待ち受け”用)。
abstract class ScreenWake {
  /// 画面を常時オンにするか切り替える。
  Future<void> setEnabled(bool enabled);
}
