import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Stores larger payloads (the content cache) as files, keeping
/// SharedPreferences for small settings only.
abstract class BlobStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// File-backed store under the app's support directory.
/// All failures degrade to "no cache" instead of crashing.
class FileBlobStore implements BlobStore {
  FileBlobStore({Future<Directory> Function()? directory})
      : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;

  Future<File> _file(String key) async {
    final dir = await _directory();
    return File('${dir.path}${Platform.pathSeparator}$key');
  }

  @override
  Future<String?> read(String key) async {
    try {
      final file = await _file(key);
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      final file = await _file(key);
      // Write then rename, so a crash mid-write can't corrupt the cache.
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(value, flush: true);
      await tmp.rename(file.path);
    } catch (_) {
      // Caching is best-effort.
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      final file = await _file(key);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}

/// In-memory store for tests.
class MemoryBlobStore implements BlobStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}
