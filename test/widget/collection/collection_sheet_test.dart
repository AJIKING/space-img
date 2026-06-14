import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/application/collection_controller.dart';
import 'package:orbit/src/domain/photos/photo.dart';
import 'package:orbit/src/ui/collection/collection_sheet.dart';

import '../../fixtures/in_memory_collection_store.dart';
import '../../fixtures/sample_photos.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    CollectionController controller,
    void Function(Photo) onSelect,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CollectionSheet(controller: controller, onSelect: onSelect),
        ),
      ),
    );
  }

  testWidgets('空のときは案内を表示する', (tester) async {
    final controller = CollectionController(store: InMemoryCollectionStore());
    await pump(tester, controller, (_) {});

    expect(find.byKey(const Key('collection-empty')), findsOneWidget);
  });

  testWidgets('お気に入りのセルが並び、タップで onSelect が呼ばれる', (tester) async {
    final controller = CollectionController(
      store: InMemoryCollectionStore([samplePhoto('a'), samplePhoto('b')]),
    );
    await controller.load();
    Photo? selected;
    await pump(tester, controller, (p) => selected = p);

    expect(find.byKey(const Key('collection-cell-a')), findsOneWidget);
    expect(find.byKey(const Key('collection-cell-b')), findsOneWidget);

    await tester.tap(find.byKey(const Key('collection-cell-a')));
    await tester.pump();

    expect(selected!.id, 'a');
  });
}
