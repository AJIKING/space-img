import '../photos/photo.dart';

/// 写真の保存・壁紙適用のプラットフォーム境界。
///
/// iOS はアプリからの壁紙直接設定が OS 仕様で不可。よって基本は「フォトに保存
/// → ユーザーが設定アプリで壁紙にする」。Android は直接適用もできる
/// ([supportsDirectSet] が true)。テストではフェイクに差し替える。
abstract class WallpaperService {
  /// この端末でアプリから壁紙へ直接適用できるか(iOS は false)。
  bool get supportsDirectSet;

  /// 写真を端末のフォト / ギャラリーに保存する。
  Future<void> saveToGallery(Photo photo);

  /// 壁紙に直接適用する([supportsDirectSet] が true の端末のみ)。
  Future<void> setAsWallpaper(Photo photo);
}
