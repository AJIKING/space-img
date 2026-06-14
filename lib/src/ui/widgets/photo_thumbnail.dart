import 'package:flutter/material.dart';

import '../../domain/photos/photo.dart';
import '../theme/orbit_theme.dart';
import '../viewer/photo_layer.dart' show photoImageProvider;

/// 写真のサムネイル(コレクションセル等)。実画像を [BoxFit.cover] で表示し、
/// 読めなければ暗い背景にフォールバックする。
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
        const ColoredBox(color: OrbitColors.void2),
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
