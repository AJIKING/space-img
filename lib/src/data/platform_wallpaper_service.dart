import 'dart:io';
import 'dart:typed_data';

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/photos/photo.dart';
import '../domain/platform/wallpaper_service.dart';

/// [WallpaperService] の本番実装。
///
/// - 保存: `gal` の `putImageBytes` でフォトへ(キャッシュは拡張子なし `.img`
///   なので**バイト列で保存**する。`putImage(path)` は拡張子判定で失敗する)。
///   アルバム指定はしない = 追加のみの権限([NSPhotoLibraryAddUsageDescription]
///   だけで済み、旧 Android のストレージ権限も不要)。
/// - 直接適用: Android のみ `async_wallpaper`(iOS は OS 仕様で不可)。
class PlatformWallpaperService implements WallpaperService {
  const PlatformWallpaperService();

  @override
  bool get supportsDirectSet => Platform.isAndroid;

  @override
  Future<void> saveToGallery(Photo photo) async {
    await Gal.putImageBytes(await _bytes(photo), name: 'orbit_${photo.id}');
  }

  @override
  Future<void> setAsWallpaper(Photo photo) async {
    if (!supportsDirectSet) {
      throw UnsupportedError('この端末では壁紙の直接設定はできません');
    }
    // async_wallpaper は失敗時に例外でなく false を返すので、明示的に例外化する。
    final ok = await AsyncWallpaper.setWallpaperFromFile(
      filePath: await _ensureLocalFile(photo),
      wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
    );
    if (!ok) throw Exception('壁紙の設定に失敗しました');
  }

  /// 写真のバイト列を得る(キャッシュファイル or 同梱アセット)。
  Future<Uint8List> _bytes(Photo photo) async {
    final ref = photo.imageRef;
    if (ref.startsWith('assets/')) {
      return (await rootBundle.load(ref)).buffer.asUint8List();
    }
    return File(ref).readAsBytes();
  }

  /// 壁紙適用にはファイルパスが要る。アセットは一時ファイルへ書き出す。
  /// キャッシュ(`.img`)は内容で復号されるためパスのまま渡せる。
  Future<String> _ensureLocalFile(Photo photo) async {
    final ref = photo.imageRef;
    if (!ref.startsWith('assets/')) return ref;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/orbit_${photo.id}.jpg');
    await file.writeAsBytes(await _bytes(photo), flush: true);
    return file.path;
  }
}
