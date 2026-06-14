import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/domain/platform/wallpaper_service.dart';

/// 設定可能な [WallpaperService] fake。保存・適用の呼び出しを記録する。
class FakeWallpaperService implements WallpaperService {
  FakeWallpaperService({
    this.supportsDirectSet = false,
    this.failSave = false,
    this.failSet = false,
  });

  @override
  bool supportsDirectSet;
  bool failSave;
  bool failSet;

  final List<Photo> saved = [];
  final List<Photo> setAsWall = [];

  @override
  Future<void> saveToGallery(Photo photo) async {
    if (failSave) throw Exception('save failed (fake)');
    saved.add(photo);
  }

  @override
  Future<void> setAsWallpaper(Photo photo) async {
    if (failSet) throw Exception('set failed (fake)');
    setAsWall.add(photo);
  }
}
