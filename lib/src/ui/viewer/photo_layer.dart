import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/photos/photo.dart';
import '../theme/orbit_theme.dart';

/// [Photo.imageRef] から表示用の [ImageProvider] を決める。
///
/// - 空文字 → null(画像なし。グラデーションのみ)。
/// - `assets/` 始まり → バンドルアセット([AssetImage]。同梱シード用)。
/// - それ以外 → ローカルファイル([FileImage]。ImageStore がキャッシュした実体)。
ImageProvider? photoImageProvider(String imageRef) {
  if (imageRef.isEmpty) return null;
  if (imageRef.startsWith('assets/')) return AssetImage(imageRef);
  return FileImage(File(imageRef));
}

/// 写真レイヤ。写真が変わるとクロスフェードする。
///
/// キャッシュ済み実画像を [BoxFit.cover] で表示し、読み込めない場合(ファイル
/// 欠落・アセット未配置・テスト環境など)は**カテゴリ別グラデーションへ
/// フォールバック**する。golden では実ファイルが無いためグラデで安定する
/// (ADR 0002 の「写真はプレースホルダ」方針とも整合)。
class PhotoLayer extends StatelessWidget {
  const PhotoLayer({super.key, required this.photo, this.kenBurns = false});

  final Photo? photo;
  final bool kenBurns;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      child: _Slide(
        key: ValueKey(photo?.id ?? '__empty__'),
        photo: photo,
        kenBurns: kenBurns,
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({super.key, required this.photo, required this.kenBurns});

  final Photo? photo;
  final bool kenBurns;

  @override
  Widget build(BuildContext context) {
    final provider = photo == null ? null : photoImageProvider(photo!.imageRef);
    final content = Stack(
      fit: StackFit.expand,
      children: [
        // 常にカテゴリ別グラデを下敷きに(画像読込中・失敗時のフォールバック)。
        DecoratedBox(
          decoration: BoxDecoration(gradient: _gradientFor(photo?.category)),
        ),
        if (provider != null)
          Image(
            image: provider,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            // 読み込めなければ下敷きのグラデを見せる。
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        const _Vignette(),
      ],
    );
    // Ken Burns はゆっくりズーム。アニメーションはアンビエント実装で本格化する。
    return SizedBox.expand(
      child: kenBurns ? Transform.scale(scale: 1.08, child: content) : content,
    );
  }
}

/// 可読性のための上下ビネット(プロトタイプの .slide::after 相当)。
class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x8C060912), Color(0x00060912), Color(0xC7060912)],
          stops: [0.0, 0.32, 1.0],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

/// カテゴリごとの深宇宙グラデーション(プロトタイプのパレットを簡略化)。
LinearGradient _gradientFor(PhotoCategory? category) {
  final List<Color> colors = switch (category) {
    PhotoCategory.nebula => [const Color(0xFF7A3CFF), OrbitColors.voidColor],
    PhotoCategory.galaxy => [const Color(0xFFFF9E5C), OrbitColors.voidColor],
    PhotoCategory.earth => [const Color(0xFF3CA7FF), OrbitColors.voidColor],
    PhotoCategory.mars => [const Color(0xFFFF7A3C), OrbitColors.voidColor],
    PhotoCategory.moon => [const Color(0xFF8A8AA0), OrbitColors.voidColor],
    PhotoCategory.jupiter => [const Color(0xFFD9A066), OrbitColors.voidColor],
    PhotoCategory.sun => [const Color(0xFFFFD23C), OrbitColors.voidColor],
    PhotoCategory.deepField => [const Color(0xFF9BB8FF), OrbitColors.voidColor],
    PhotoCategory.aurora => [const Color(0xFF3CFF9E), OrbitColors.voidColor],
    PhotoCategory.saturn => [const Color(0xFFE0C28A), OrbitColors.voidColor],
    null => [OrbitColors.void2, OrbitColors.voidColor],
  };
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: colors,
  );
}
