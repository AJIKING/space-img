import '../domain/photos/photo.dart';

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
