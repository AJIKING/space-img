import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/photos/photo.dart';
import '../domain/settings/settings_store.dart';
import '../domain/settings/viewer_settings.dart';

/// [SettingsStore] の本番実装。設定を shared_preferences に単一 JSON キーで保存する。
///
/// 各フィールドは欠落時に既定値へフォールバックして読むので、スキーマに項目が
/// 増えても旧データを壊さない。壊れた JSON は null を返して既定値起動にする。
class PrefsSettingsStore implements SettingsStore {
  PrefsSettingsStore();

  SharedPreferences? _prefs;

  static const String storageKey = 'viewer_settings_v1';

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<ViewerSettings?> load() async {
    final raw = (await _instance).getString(storageKey);
    if (raw == null) return null;
    try {
      return _decode(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(ViewerSettings s) async {
    await (await _instance).setString(storageKey, jsonEncode(_encode(s)));
  }

  static Map<String, dynamic> _encode(ViewerSettings s) => {
    'category': s.category.name,
    'showClock': s.showClock,
    'clockPosition': s.clockPosition.name,
    'clockSize': s.clockSize.name,
    'use24h': s.use24h,
    'showTelemetry': s.showTelemetry,
    'showReticle': s.showReticle,
    'showMeta': s.showMeta,
    'autoAdvance': s.autoAdvance,
    'intervalSeconds': s.intervalSeconds,
    'kenBurns': s.kenBurns,
    'sleepMinutes': s.sleepMinutes,
  };

  static ViewerSettings _decode(Map<String, dynamic> j) {
    const d = ViewerSettings();
    return ViewerSettings(
      category: PhotoCategory.values.asNameMap()[j['category']] ?? d.category,
      showClock: j['showClock'] as bool? ?? d.showClock,
      clockPosition:
          ClockPosition.values.asNameMap()[j['clockPosition']] ??
          d.clockPosition,
      clockSize: ClockSize.values.asNameMap()[j['clockSize']] ?? d.clockSize,
      use24h: j['use24h'] as bool? ?? d.use24h,
      showTelemetry: j['showTelemetry'] as bool? ?? d.showTelemetry,
      showReticle: j['showReticle'] as bool? ?? d.showReticle,
      showMeta: j['showMeta'] as bool? ?? d.showMeta,
      autoAdvance: j['autoAdvance'] as bool? ?? d.autoAdvance,
      intervalSeconds: j['intervalSeconds'] as int? ?? d.intervalSeconds,
      kenBurns: j['kenBurns'] as bool? ?? d.kenBurns,
      sleepMinutes: j['sleepMinutes'] as int? ?? d.sleepMinutes,
    );
  }
}
