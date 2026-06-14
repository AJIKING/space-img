import 'package:flutter/material.dart';

/// デザイントークン(プロトタイプ orbit_space_wallpaper_app.html の `:root` 準拠)。
abstract final class OrbitColors {
  static const Color voidColor = Color(0xFF060912);
  static const Color void2 = Color(0xFF0B1020);
  static const Color hud = Color(0xFFE8ECF2);
  static const Color muted = Color(0xFF6E7891);
  static const Color amber = Color(0xFFF5A623);
  static const Color line = Color(0x29E8ECF2); // alpha .16
  static const Color lineStrong = Color(0x57E8ECF2); // alpha .34
}

/// HUD で使うテキストスタイル。フォントは未バンドルのため当面はデフォルト書体。
/// 実装フェーズで Space Grotesk / Space Mono / Noto Sans JP を当てる。
abstract final class OrbitText {
  static const TextStyle mono = TextStyle(
    color: OrbitColors.hud,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: 1,
  );

  static const TextStyle display = TextStyle(
    color: OrbitColors.hud,
    fontWeight: FontWeight.w600,
  );
}

/// アプリ全体のテーマ(常時ダーク基調)。
ThemeData buildOrbitTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: OrbitColors.voidColor,
  colorScheme: const ColorScheme.dark(
    primary: OrbitColors.amber,
    surface: OrbitColors.voidColor,
  ),
  useMaterial3: true,
);
