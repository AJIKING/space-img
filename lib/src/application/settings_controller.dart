import 'package:flutter/foundation.dart';

import '../domain/settings/settings_store.dart';
import '../domain/settings/viewer_settings.dart';

/// カスタマイズ設定の保持・更新・永続化(ChangeNotifier)。
///
/// UI(TUNE シート)は [settings] を読み、[update] で書き換える。書き換えは
/// 即座に通知され(HUD などがライブで反映)、同時に [SettingsStore] へ保存される。
class SettingsController extends ChangeNotifier {
  SettingsController({
    required this.store,
    ViewerSettings initial = const ViewerSettings(),
  }) : _settings = initial;

  final SettingsStore store;
  ViewerSettings _settings;

  ViewerSettings get settings => _settings;

  /// 起動時: 保存済み設定があれば適用する。無ければ既定値のまま。
  Future<void> load() async {
    final loaded = await store.load();
    if (loaded != null) {
      _settings = loaded;
      notifyListeners();
    }
  }

  /// 設定を丸ごと差し替えて通知 + 永続化する。
  Future<void> update(ViewerSettings settings) async {
    _settings = settings;
    notifyListeners();
    // 永続化失敗は次回起動への影響にとどめ、未処理例外にしない。
    try {
      await store.save(settings);
    } catch (_) {}
  }
}
