import 'package:flutter/material.dart';

import '../../domain/photos/photo.dart';
import '../format.dart';
import '../theme/orbit_theme.dart';
import '../widgets/photo_thumbnail.dart';

/// WALLPAPER プレビュー。現在の写真をロック画面風(日付 + 時刻)に見せる。
///
/// 実機でのロック画面壁紙の自動適用は OS 制約が強く scope 外(写真保存 + OS の
/// 壁紙設定への誘導にとどめる。docs/product-spec.md)。
class WallpaperPreview extends StatelessWidget {
  const WallpaperPreview({super.key, required this.photo, required this.now});

  final Photo photo;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
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
                formatDate(now).toUpperCase(),
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
                  const Text(
                    'これがロック画面でのイメージです。\n実機では写真を保存 → OS の壁紙設定から適用します。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('wallpaper-apply'),
                      style: FilledButton.styleFrom(
                        backgroundColor: OrbitColors.amber,
                        foregroundColor: const Color(0xFF0A0E1A),
                      ),
                      onPressed: () {
                        Navigator.of(context).maybePop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('待ち受けに設定しました(デモ)'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text('この宇宙を待ち受けにする'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      key: const Key('wallpaper-close'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text(
                        '閉じる',
                        style: TextStyle(color: OrbitColors.hud),
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
) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => Dialog.fullscreen(
      backgroundColor: OrbitColors.voidColor,
      child: WallpaperPreview(photo: photo, now: now),
    ),
  );
}
