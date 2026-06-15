import 'package:flutter/material.dart';

import '../theme/orbit_theme.dart';

/// ビューア下部のドック(SAVE / SAVED / WALLPAPER / TUNE)。
///
/// 各シート・お気に入りの実装は別タスク。ここではボタンと callback・semantics
/// だけを提供する。[isSaved] は SAVE のオン状態(お気に入り済み)。
class Dock extends StatelessWidget {
  const Dock({
    super.key,
    required this.onSave,
    required this.onCollection,
    required this.onWallpaper,
    required this.onCustomize,
    this.isSaved = false,
  });

  final VoidCallback onSave;
  final VoidCallback onCollection;
  final VoidCallback onWallpaper;
  final VoidCallback onCustomize;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22, left: 8, right: 8),
      child: Row(
        children: [
          Expanded(
            child: _DockButton(
              buttonKey: const Key('dock-save'),
              icon: isSaved ? Icons.favorite : Icons.favorite_border,
              label: 'SAVE',
              semanticLabel: 'お気に入りに追加',
              active: isSaved,
              onTap: onSave,
            ),
          ),
          Expanded(
            child: _DockButton(
              buttonKey: const Key('dock-saved'),
              icon: Icons.grid_view_rounded,
              label: 'SAVED',
              semanticLabel: 'コレクションを開く',
              onTap: onCollection,
            ),
          ),
          Expanded(
            child: _DockButton(
              buttonKey: const Key('dock-wallpaper'),
              icon: Icons.smartphone,
              label: 'WALLPAPER',
              semanticLabel: '待ち受けプレビュー',
              onTap: onWallpaper,
            ),
          ),
          Expanded(
            child: _DockButton(
              buttonKey: const Key('dock-tune'),
              icon: Icons.tune,
              label: 'TUNE',
              semanticLabel: 'カスタマイズ',
              onTap: onCustomize,
            ),
          ),
        ],
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.active = false,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? OrbitColors.amber : OrbitColors.muted;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OrbitText.mono.copyWith(
                  fontSize: 9,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
