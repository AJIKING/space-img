import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/pool/image_store.dart';

/// [ImageStore] の本番実装。画像をアプリ専用ディレクトリ配下にファイルとして
/// 保存する。ファイル名は id の SHA-1(衝突しない安定キー)+ `.img`。
///
/// テストでは [directory] に一時ディレクトリを渡してファイル I/O を完結させる
/// (path_provider のプラットフォームチャネルに依存しない)。
class FileImageStore implements ImageStore {
  FileImageStore({Directory? directory}) : _override = directory;

  final Directory? _override;
  Directory? _dir;

  Future<Directory> get _cacheDir async {
    final cached = _dir;
    if (cached != null) return cached;
    final base = _override ?? await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/photo_pool');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return _dir = dir;
  }

  String _fileName(String id) => '${sha1.convert(utf8.encode(id))}.img';

  @override
  Future<String> store(String id, Uint8List bytes) async {
    final dir = await _cacheDir;
    final file = File('${dir.path}/${_fileName(id)}');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<void> retainOnly(Set<String> keepIds) async {
    final dir = await _cacheDir;
    final keepNames = keepIds.map(_fileName).toSet();
    await for (final entity in dir.list()) {
      if (entity is File) {
        final name = entity.uri.pathSegments.last;
        if (!keepNames.contains(name)) {
          await entity.delete();
        }
      }
    }
  }
}
