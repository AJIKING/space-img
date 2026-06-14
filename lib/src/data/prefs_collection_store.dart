import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/collection/collection_store.dart';
import '../domain/photos/photo.dart';
import 'photo_codec.dart';

/// [CollectionStore] の本番実装。お気に入りを shared_preferences に
/// 単一 JSON 配列で保存する。**壊れた JSON は例外にせず空リスト**。
class PrefsCollectionStore implements CollectionStore {
  PrefsCollectionStore();

  SharedPreferences? _prefs;

  static const String storageKey = 'favorites_v1';

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<List<Photo>> load() async {
    final raw = (await _instance).getString(storageKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => photoFromJson(e as Map<String, dynamic>))
          .whereType<Photo>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<Photo> favorites) async {
    final encoded = jsonEncode(favorites.map(photoToJson).toList());
    await (await _instance).setString(storageKey, encoded);
  }
}
