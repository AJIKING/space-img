import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/collection/collection_store.dart';
import '../domain/photos/photo.dart';
import 'photo_codec.dart';

/// [CollectionStore] の本番実装。お気に入りを shared_preferences に
/// 単一 JSON 配列で保存する。**壊れた JSON は例外にせず空リスト**。
class PrefsCollectionStore implements CollectionStore {
  PrefsCollectionStore({required this.cacheDirPath});

  /// 現在のキャッシュディレクトリ絶対パス(画像参照の再ベース用。iOS のコンテナ
  /// パス変化対策)。本番は FileImageStore.directoryPath、テストは固定値。
  final Future<String> Function() cacheDirPath;

  SharedPreferences? _prefs;

  static const String storageKey = 'favorites_v1';

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<List<Photo>> load() async {
    final raw = (await _instance).getString(storageKey);
    if (raw == null) return [];
    try {
      final dir = await cacheDirPath();
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => e as Map<String, dynamic>)
          .map((m) {
            final ref = m['imageRef'];
            return ref is String
                ? {...m, 'imageRef': resolveCachedRef(ref, dir)}
                : m;
          })
          .map(photoFromJson)
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
