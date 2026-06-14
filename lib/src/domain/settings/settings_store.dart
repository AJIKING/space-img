import 'viewer_settings.dart';

/// カスタマイズ設定([ViewerSettings])の永続化境界。
abstract class SettingsStore {
  /// 保存済み設定を読む。未保存なら null。**壊れたデータでも例外を投げず null**
  /// を返し、既定値で起動させる。
  Future<ViewerSettings?> load();

  /// 設定を保存する。
  Future<void> save(ViewerSettings settings);
}
