import 'package:flutter/foundation.dart';

import '../domain/collection/collection_store.dart';
import '../domain/photos/photo.dart';

/// お気に入り(コレクション)の保持・トグル・永続化(ChangeNotifier)。
class CollectionController extends ChangeNotifier {
  CollectionController({required this.store});

  final CollectionStore store;

  List<Photo> _favorites = [];

  /// 新しい順のお気に入り一覧(読み取り専用)。
  List<Photo> get favorites => List.unmodifiable(_favorites);

  bool get isEmpty => _favorites.isEmpty;

  bool isFavorite(Photo photo) => _favorites.any((f) => f.id == photo.id);

  /// 起動時: 保存済みお気に入りを読む。
  Future<void> load() async {
    _favorites = await store.load();
    notifyListeners();
  }

  /// お気に入りを切り替える(無ければ先頭に追加、あれば除外)。即座に永続化。
  Future<void> toggle(Photo photo) async {
    if (isFavorite(photo)) {
      _favorites = _favorites.where((f) => f.id != photo.id).toList();
    } else {
      _favorites = [photo, ..._favorites];
    }
    notifyListeners();
    // 永続化失敗は次回起動への影響にとどめ、未処理例外にしない。
    try {
      await store.save(_favorites);
    } catch (_) {}
  }
}
