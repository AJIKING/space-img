import 'package:orbit/src/domain/settings/settings_store.dart';
import 'package:orbit/src/domain/settings/viewer_settings.dart';

/// インメモリの [SettingsStore] fake。保存内容と回数を検証できる。
class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([this._saved]);

  ViewerSettings? _saved;
  int saveCount = 0;

  ViewerSettings? get saved => _saved;

  @override
  Future<ViewerSettings?> load() async => _saved;

  @override
  Future<void> save(ViewerSettings settings) async {
    _saved = settings;
    saveCount++;
  }
}
