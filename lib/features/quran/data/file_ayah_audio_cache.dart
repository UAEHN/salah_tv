import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/i_ayah_audio_cache.dart';

/// File-based [IAyahAudioCache] implementation.
///
/// Cache layout (paths joined with the platform separator):
///   `appDocs/ayah_audio_cache/{reciterId}/{sss}{aaa}.mp3`
/// Deterministic so cache lookups are O(1) and a clear cache simply
/// removes the directory.
class FileAyahAudioCache implements IAyahAudioCache {
  final Dio _dio;
  Directory? _rootDir;

  FileAyahAudioCache(this._dio);

  @override
  Future<String?> getOrDownload({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
    required String url,
  }) async {
    try {
      final root = await _ensureRoot();
      final fileName =
          '${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3';
      final dirPath = p.join(root.path, reciterId);
      final filePath = p.join(dirPath, fileName);
      final file = File(filePath);
      if (await file.exists() && await file.length() > 0) {
        return filePath;
      }
      await Directory(dirPath).create(recursive: true);
      final res = await _dio.download(
        url,
        filePath,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 12),
        ),
      );
      if (res.statusCode != 200) {
        await _safeDelete(file);
        return null;
      }
      return filePath;
    } catch (e) {
      debugPrint('[AyahCache] download failed: $e');
      return null;
    }
  }

  Future<Directory> _ensureRoot() async {
    final cached = _rootDir;
    if (cached != null) return cached;
    final base = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(base.path, 'ayah_audio_cache'));
    await root.create(recursive: true);
    _rootDir = root;
    return root;
  }

  Future<void> _safeDelete(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {
      /* ignore */
    }
  }
}
