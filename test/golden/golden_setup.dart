import 'dart:io';

import 'package:flutter/material.dart';
import 'package:orbit/src/ui/theme/orbit_theme.dart';

/// golden の基準 platform は CI の Linux(ADR 0002)。開発機(Windows / macOS)
/// では platform 差でフォントレンダリングが一致しないため自動 skip する。
final bool skipGoldens = !Platform.isLinux;

/// golden 用の決定的なラッパー(固定テーマ・暗い背景)。
/// device size は各テストで `tester.binding.setSurfaceSize` で固定する。
Widget goldenApp(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildOrbitTheme(),
  home: Scaffold(backgroundColor: OrbitColors.voidColor, body: child),
);
