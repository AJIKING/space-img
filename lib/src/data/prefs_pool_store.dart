import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/photos/photo.dart';
import '../domain/pool/photo_pool.dart';
import '../domain/pool/pool_store.dart';
import 'photo_codec.dart';

/// [PoolStore] の本番実装。プールのメタデータを shared_preferences に
/// **カテゴリごとの JSON キー**で保存する(画像バイナリ自体は [ImageStore] が持つ)。
///
/// スキーマを変えるときは新しいキー接頭辞(`photo_pool_v2_` …)を切り、旧キーから
/// 移行する(ADR 0001 の永続化方針)。**壊れた JSON は例外にせず null**。
class PrefsPoolStore implements PoolStore {
  PrefsPoolStore();

  SharedPreferences? _prefs;

  /// スキーマバージョン付きキー接頭辞。実際のキーは接頭辞 + カテゴリ名。
  static const String storageKeyPrefix = 'photo_pool_v1_';

  static String keyFor(PhotoCategory category) =>
      '$storageKeyPrefix${category.name}';

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<PhotoPool?> load(PhotoCategory category) async {
    final raw = (await _instance).getString(keyFor(category));
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final photos = (map['photos'] as List)
          .map((e) => photoFromJson(e as Map<String, dynamic>))
          .whereType<Photo>()
          .toList();
      final ts = map['lastRefreshedAt'] as int?;
      return PhotoPool(
        photos: photos,
        lastRefreshedAt: ts == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(ts),
      );
    } catch (_) {
      // 壊れたデータ・型不一致は初回起動扱い(ADR 0004)。
      return null;
    }
  }

  @override
  Future<void> save(PhotoCategory category, PhotoPool pool) async {
    final map = <String, dynamic>{
      'photos': pool.photos.map(photoToJson).toList(),
      'lastRefreshedAt': pool.lastRefreshedAt?.millisecondsSinceEpoch,
    };
    await (await _instance).setString(keyFor(category), jsonEncode(map));
  }
}
