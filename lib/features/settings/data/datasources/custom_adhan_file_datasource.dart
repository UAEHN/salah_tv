import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/failures.dart';

/// Manages custom adhan audio files under `{app_docs}/custom_adhans/`.
/// Throws [StorageException] on any I/O, validation, or size failure.
class CustomAdhanFileDataSource {
  static const String _subdir = 'custom_adhans';
  static const int _maxBytes = 8 * 1024 * 1024; // 8 MB
  static const List<String> _allowedExts = ['.mp3', '.wav', '.ogg', '.m4a'];

  Future<Directory> _ensureDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _subdir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Copies [srcPath] into the app dir using a name derived from [id] and
  /// the source extension. Returns the resolved file name (basename).
  Future<String> copyToAppDir(String srcPath, String id) async {
    final src = File(srcPath);
    if (!await src.exists()) {
      throw const StorageException('Source file does not exist');
    }
    final ext = p.extension(srcPath).toLowerCase();
    if (!_allowedExts.contains(ext)) {
      throw StorageException('Unsupported audio format: $ext');
    }
    final size = await src.length();
    if (size <= 0) {
      throw const StorageException('Source file is empty');
    }
    if (size > _maxBytes) {
      throw const StorageException('Audio file exceeds 8 MB limit');
    }
    final dir = await _ensureDir();
    final fileName = '$id$ext';
    final dst = File(p.join(dir.path, fileName));
    await src.copy(dst.path);
    return fileName;
  }

  /// Idempotent: missing file is not an error.
  Future<void> deleteFromAppDir(String fileName) async {
    try {
      final dir = await _ensureDir();
      final file = File(p.join(dir.path, fileName));
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (e) {
      throw StorageException('Failed to delete custom adhan: ${e.message}');
    }
  }

  Future<String> resolvePath(String fileName) async {
    final dir = await _ensureDir();
    final path = p.join(dir.path, fileName);
    if (!await File(path).exists()) {
      throw StorageException('Custom adhan file missing: $fileName');
    }
    return path;
  }
}
