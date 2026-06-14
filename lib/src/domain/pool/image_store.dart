import 'dart:typed_data';

/// 画像バイナリのローカルキャッシュ境界(プールの実体)。
///
/// テストではインメモリ fake に差し替える。Flutter の `ImageCache` と名前が
/// 衝突しないよう `ImageStore` とする。
abstract class ImageStore {
  /// [id] の画像を保存し、表示で使う参照(ファイルパス等)を返す。
  Future<String> store(String id, Uint8List bytes);

  /// [keepIds] に含まれない保存済み画像を削除する(プール入れ替え時の掃除)。
  Future<void> retainOnly(Set<String> keepIds);
}
