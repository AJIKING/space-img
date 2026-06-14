import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/src/application/collection_controller.dart';

import '../../fixtures/in_memory_collection_store.dart';
import '../../fixtures/sample_photos.dart';

void main() {
  test('load: 保存済みお気に入りを読む', () async {
    final controller = CollectionController(
      store: InMemoryCollectionStore([samplePhoto('a')]),
    );

    await controller.load();

    expect(controller.favorites.map((p) => p.id), ['a']);
    expect(controller.isFavorite(samplePhoto('a')), isTrue);
  });

  test('toggle: 追加は先頭に積み、永続化する', () async {
    final store = InMemoryCollectionStore();
    final controller = CollectionController(store: store);

    await controller.toggle(samplePhoto('a'));
    await controller.toggle(samplePhoto('b'));

    expect(controller.favorites.map((p) => p.id), ['b', 'a']);
    expect(store.saved.map((p) => p.id), ['b', 'a']);
  });

  test('toggle: 既存は除外する', () async {
    final controller = CollectionController(
      store: InMemoryCollectionStore([samplePhoto('a'), samplePhoto('b')]),
    );
    await controller.load();

    await controller.toggle(samplePhoto('a'));

    expect(controller.favorites.map((p) => p.id), ['b']);
    expect(controller.isFavorite(samplePhoto('a')), isFalse);
  });

  test('toggle で通知する', () async {
    final controller = CollectionController(store: InMemoryCollectionStore());
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.toggle(samplePhoto('a'));

    expect(notified, 1);
  });
}
