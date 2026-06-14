import 'package:flutter/material.dart';

import '../../domain/photos/photo.dart';
import '../category_gradient.dart';
import '../viewer/photo_layer.dart' show photoImageProvider;

/// 写真のサムネイル(コレクションセル等)。実画像を [BoxFit.cover] で表示し、
/// 読めなければ**カテゴリ別グラデーション**にフォールバックする(真っ黒で
/// 「空」に見えるのを避ける)。
class PhotoThumbnail extends StatelessWidget {
  const PhotoThumbnail({
    super.key,
    required this.photo,
    this.fit = BoxFit.cover,
  });

  final Photo photo;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final provider = photoImageProvider(photo.imageRef);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: categoryGradient(photo.category)),
        ),
        if (provider != null)
          Image(
            image: provider,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
      ],
    );
  }
}
