import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/photos/photo.dart';
import '../../domain/platform/wallpaper_service.dart';
import '../format.dart';
import '../theme/orbit_theme.dart';
import '../widgets/photo_thumbnail.dart';

/// WALLPAPER プレビュー。現在の写真をロック画面風(日付 + 時刻)に見せ、
/// 「写真を保存」(両 OS)と、対応端末(Android)では「壁紙に設定」を提供する。
///
/// iOS はアプリからの壁紙直接設定が OS 仕様で不可なので、保存してユーザーが
/// 設定アプリで壁紙にする導線にする。
class WallpaperPreview extends StatelessWidget {
  const WallpaperPreview({
    super.key,
    required this.photo,
    required this.now,
    required this.service,
  });

  final Photo photo;
  final DateTime now;
  final WallpaperService service;

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    String message;
    try {
      await service.saveToGallery(photo);
      message = service.supportsDirectSet
          ? l10n.saveSuccess
          : l10n.saveSuccessIos;
    } catch (_) {
      message = l10n.saveFailed;
    }
    navigator.maybePop();
    messenger.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _setWallpaper(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    String message;
    try {
      await service.setAsWallpaper(photo);
      message = l10n.wallpaperSetSuccess;
    } catch (_) {
      message = l10n.wallpaperSetFailed;
    }
    navigator.maybePop();
    messenger.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        PhotoThumbnail(photo: photo),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x59000000), Color(0x00000000), Color(0x80000000)],
              stops: [0.0, 0.35, 1.0],
            ),
          ),
        ),
        // ロック画面の時計
        Align(
          alignment: const Alignment(0, -0.55),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.hudDate(now).toUpperCase(),
                style: OrbitText.display.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatClock(now, use24h: true),
                style: OrbitText.mono.copyWith(
                  fontSize: 72,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        // アクション
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.supportsDirectSet
                        ? l10n.wallpaperHintAndroid
                        : l10n.wallpaperHintIos,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (service.supportsDirectSet) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('wallpaper-set'),
                        style: FilledButton.styleFrom(
                          backgroundColor: OrbitColors.amber,
                          foregroundColor: const Color(0xFF0A0E1A),
                        ),
                        onPressed: () => _setWallpaper(context),
                        child: Text(l10n.wallpaperSetButton),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        key: const Key('wallpaper-save'),
                        onPressed: () => _save(context),
                        child: Text(
                          l10n.savePhotoButton,
                          style: const TextStyle(color: OrbitColors.hud),
                        ),
                      ),
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('wallpaper-save'),
                        style: FilledButton.styleFrom(
                          backgroundColor: OrbitColors.amber,
                          foregroundColor: const Color(0xFF0A0E1A),
                        ),
                        onPressed: () => _save(context),
                        child: Text(l10n.savePhotoButton),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      key: const Key('wallpaper-close'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(
                        l10n.close,
                        style: const TextStyle(color: OrbitColors.hud),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// WALLPAPER プレビューを全画面ダイアログで開くヘルパー。
Future<void> showWallpaperPreview(
  BuildContext context,
  Photo photo,
  DateTime now,
  WallpaperService service,
) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => Dialog.fullscreen(
      backgroundColor: OrbitColors.voidColor,
      child: WallpaperPreview(photo: photo, now: now, service: service),
    ),
  );
}
