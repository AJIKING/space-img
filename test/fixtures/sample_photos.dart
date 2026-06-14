import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/photos/photo_source.dart';

/// テスト用の [Photo] を簡潔に作るヘルパー。
Photo samplePhoto(String id, {PhotoCategory category = PhotoCategory.nebula}) =>
    Photo(
      id: id,
      title: 'title-$id',
      center: 'STScI',
      category: category,
      imageRef: 'mem://$id',
    );

/// テスト用の [RemotePhoto](補充候補)を作るヘルパー。
/// [imageUrl] は `https://img/<id>.jpg`(ダウンロード失敗の指定に使う)。
RemotePhoto sampleRemote(
  String id, {
  PhotoCategory category = PhotoCategory.nebula,
}) => RemotePhoto(
  id: id,
  title: 'title-$id',
  center: 'STScI',
  category: category,
  imageUrl: 'https://img/$id.jpg',
);
