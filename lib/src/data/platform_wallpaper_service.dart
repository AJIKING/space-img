import 'dart:io';

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/photos/photo.dart';
import '../domain/platform/wallpaper_service.dart';

/// [WallpaperService] の本番実装。
///
/// - 保存: `gal` でフォト / ギャラリーへ。
/// - 直接適用: Android のみ `async_wallpaper`(iOS は OS 仕様で不可)。
class PlatformWallpaperService implements WallpaperService {
  const PlatformWallpaperService();

  @override
  bool get supportsDirectSet => Platform.isAndroid;

  @override
  Future<void> saveToGallery(Photo photo) async {
    await Gal.putImage(await _ensureLocalFile(photo), album: 'ORBIT');
  }

  @override
  Future<void> setAsWallpaper(Photo photo) async {
    if (!supportsDirectSet) {
      throw UnsupportedError('この端末では壁紙の直接設定はできません');
    }
    await AsyncWallpaper.setWallpaperFromFile(
      filePath: await _ensureLocalFile(photo),
      wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
    );
  }

  /// imageRef がローカルファイルパスならそのまま、アセット(同梱シード)なら
  /// 一時ファイルへ書き出してパスを返す(gal / async_wallpaper はパスを要する)。
  Future<String> _ensureLocalFile(Photo photo) async {
    final ref = photo.imageRef;
    if (!ref.startsWith('assets/')) return ref;
    final data = await rootBundle.load(ref);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/orbit_${photo.id}.jpg');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file.path;
  }
}
