import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../application/collection_controller.dart';
import '../../domain/photos/photo.dart';
import '../theme/orbit_theme.dart';
import '../widgets/photo_thumbnail.dart';

/// SAVED シート。お気に入りをグリッド表示し、タップでビューアに表示する。
class CollectionSheet extends StatelessWidget {
  const CollectionSheet({
    super.key,
    required this.controller,
    required this.onSelect,
  });

  final CollectionController controller;
  final void Function(Photo) onSelect;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final favorites = controller.favorites;
        final l10n = AppLocalizations.of(context);
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFF0A0E1A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                border: Border(top: BorderSide(color: OrbitColors.line)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context, l10n),
                  if (favorites.isEmpty)
                    Padding(
                      key: const Key('collection-empty'),
                      padding: const EdgeInsets.fromLTRB(22, 30, 22, 40),
                      child: Text(
                        l10n.collectionEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: OrbitColors.muted,
                          fontSize: 12,
                          height: 1.8,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 7,
                              mainAxisSpacing: 7,
                            ),
                        itemCount: favorites.length,
                        itemBuilder: (context, i) {
                          final photo = favorites[i];
                          return GestureDetector(
                            key: Key('collection-cell-${photo.id}'),
                            onTap: () {
                              Navigator.of(context).maybePop();
                              onSelect(photo);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: PhotoThumbnail(photo: photo),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 14, 12, 8),
    child: Row(
      children: [
        Center(
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: OrbitColors.lineStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.collectionTitle,
          style: const TextStyle(
            color: OrbitColors.hud,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        IconButton(
          key: const Key('collection-close'),
          icon: const Icon(Icons.close, color: OrbitColors.muted, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    ),
  );
}

/// SAVED シートをモーダルで開くヘルパー。
Future<void> showCollectionSheet(
  BuildContext context,
  CollectionController controller,
  void Function(Photo) onSelect,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CollectionSheet(controller: controller, onSelect: onSelect),
  );
}
