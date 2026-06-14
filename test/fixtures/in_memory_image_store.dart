import 'dart:typed_data';

import 'package:orbit/src/domain/pool/image_store.dart';

/// インメモリの [ImageStore] fake。`data` で保存内容を検証できる。
class InMemoryImageStore implements ImageStore {
  final Map<String, Uint8List> data = {};

  @override
  Future<String> store(String id, Uint8List bytes) async {
    data[id] = bytes;
    return 'mem://$id';
  }

  @override
  Future<void> retainOnly(Set<String> keepIds) async {
    data.removeWhere((key, _) => !keepIds.contains(key));
  }
}
