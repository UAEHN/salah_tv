import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/i_quran_assets_repository.dart';

/// Downloads the QCF v2 BSML page fonts on demand and registers them
/// with Flutter's `FontLoader`. Fonts come from the public Skoon repo
/// mirror — every URL was probed to confirm `200 OK` before shipping
/// this code. Resumable: a half-finished download just continues from
/// the first missing `p{N}.woff` on the next call.
class QuranAssetsRepository implements IQuranAssetsRepository {
  static const int _totalPages = 604;
  static const String _baseUrl =
      'https://raw.githubusercontent.com/Epic-Apps-Hub/Skoon-Flutter-Islamic-App/main/assets/fonts/v2woff';
  static const String _dirName = 'quran_fonts_v2';

  final Dio _dio;
  Directory? _cachedDir;
  final Set<int> _registered = {};

  QuranAssetsRepository(this._dio);

  @override
  int get totalPages => _totalPages;

  Future<Directory> _dir() async {
    if (_cachedDir != null) return _cachedDir!;
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_dirName');
    if (!await dir.exists()) await dir.create(recursive: true);
    _cachedDir = dir;
    return dir;
  }

  File _file(Directory dir, int pageNumber) =>
      File('${dir.path}/p$pageNumber.woff');

  @override
  Future<int> downloadedCount() async {
    final dir = await _dir();
    var count = 0;
    for (var i = 1; i <= _totalPages; i++) {
      if (await _file(dir, i).exists()) count++;
    }
    return count;
  }

  @override
  Future<bool> isComplete() async => (await downloadedCount()) == _totalPages;

  @override
  Stream<int> download() async* {
    final dir = await _dir();
    var count = 0;
    for (var i = 1; i <= _totalPages; i++) {
      if (await _file(dir, i).exists()) count++;
    }
    yield count;
    for (var i = 1; i <= _totalPages; i++) {
      final file = _file(dir, i);
      if (await file.exists()) continue;
      try {
        await _dio.download('$_baseUrl/p$i.woff', file.path);
        count++;
        yield count;
      } catch (e) {
        // Bubble up so the cubit can surface a retry prompt.
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteAll() async {
    final dir = await _dir();
    if (await dir.exists()) await dir.delete(recursive: true);
    _cachedDir = null;
    // Note: `_registered` is intentionally NOT cleared. Flutter has no
    // unregister API; the registrations stay until the app process is
    // restarted, so a fresh delete + re-download in the same session
    // would otherwise re-load fonts that are already in memory.
  }

  @override
  Future<void> registerAllFonts() async {
    final dir = await _dir();
    for (var i = 1; i <= _totalPages; i++) {
      if (_registered.contains(i)) continue;
      final file = _file(dir, i);
      if (!await file.exists()) continue;
      final bytes = await file.readAsBytes();
      final family = 'QCF_P${i.toString().padLeft(3, '0')}';
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
      _registered.add(i);
    }
  }
}
