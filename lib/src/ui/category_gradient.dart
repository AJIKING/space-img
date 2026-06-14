import 'package:flutter/material.dart';

import '../domain/photos/photo.dart';
import 'theme/orbit_theme.dart';

/// カテゴリごとの深宇宙グラデーション(プロトタイプのパレットを簡略化)。
/// 写真が読めないときのフォールバック背景として写真レイヤ・サムネイルで共有する。
LinearGradient categoryGradient(PhotoCategory? category) {
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
