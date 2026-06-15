import '../domain/photos/photo.dart';

/// 永続化された画像参照を、現在のキャッシュディレクトリへ再ベースする。
///
/// キャッシュ画像はファイル名(SHA-1)が安定キーなので、保存時の絶対パスでなく
/// **現在の [cacheDir] + ファイル名**で解決する。iOS はアプリ更新/復元で
/// コンテナの絶対パスが変わるため、絶対パスをそのまま信用すると参照切れになる。
/// アセット参照(`assets/`)と空文字はそのまま返す。
String resolveCachedRef(String imageRef, String cacheDir) {
  if (imageRef.isEmpty || imageRef.startsWith('assets/')) return imageRef;
  final base = imageRef.split(RegExp(r'[/\\]')).last;
  return '$cacheDir/$base';
}

/// [Photo] の JSON 変換(プール・お気に入りの永続化で共有)。

Map<String, dynamic> photoToJson(Photo p) => {
  'id': p.id,
  'title': p.title,
  'center': p.center,
  'category': p.category.name,
  'imageRef': p.imageRef,
  'date': p.date,
  'sourceUrl': p.sourceUrl,
};

/// 必須フィールド欠落・未知カテゴリの写真は null を返す(呼び出し側でスキップ)。
Photo? photoFromJson(Map<String, dynamic> j) {
  final id = j['id'];
  final title = j['title'];
  final center = j['center'];
  final imageRef = j['imageRef'];
  final category = PhotoCategory.values.asNameMap()[j['category']];
  if (id is! String ||
      title is! String ||
      center is! String ||
      imageRef is! String ||
      category == null) {
    return null;
  }
  return Photo(
    id: id,
    title: title,
    center: center,
    category: category,
    imageRef: imageRef,
    date: j['date'] as String?,
    sourceUrl: j['sourceUrl'] as String?,
  );
}
