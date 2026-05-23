import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/i_quran_assets_repository.dart';

/// Downloads the QCF v2 BSML page fonts on demand and registers them
/// lazily, per-page, with Flutter's `FontLoader`. Eager registration of
/// all 604 fonts at startup froze the UI thread for 2–6 s on mid-range
/// hardware (each `FontLoader.load()` mutates Skia's font collection on
/// the platform thread). Pages now register their own font right
/// before they paint, so startup pays zero font-load cost.
class QuranAssetsRepository implements IQuranAssetsRepository {
  static const int _totalPages = 604;
  static const String _baseUrl =
      'https://raw.githubusercontent.com/Epic-Apps-Hub/Skoon-Flutter-Islamic-App/main/assets/fonts/v2woff';
  static const String _dirName = 'quran_fonts_v2';

  final Dio _dio;
  Directory? _cachedDir;

  /// Pages already pushed to the Flutter engine. Survives across reader
  /// open/close cycles — we never have to re-register in the same
  /// process. Flutter exposes no unregister API, so a deleted-then-
  /// re-downloaded font in the same session would otherwise be loaded
  /// twice. See [deleteAll] for the related caveat.
  final Set<int> _registered = <int>{};

  /// In-flight registrations keyed by page number. Lets us coalesce
  /// concurrent `ensureFontForPage` calls — the reader's `PageView`
  /// builder fires the same page's `initState` twice in some swipe
  /// directions, and the gate's progress UI may race with it.
  final Map<int, Future<bool>> _inFlight = <int, Future<bool>>{};

  /// Pages whose `.woff` is present on disk. Cached after the first
  /// `downloadedCount()` / `ensureFontForPage()` call so subsequent
  /// page-flips don't pay another `Directory.list()` cost. Invalidated
  /// after [deleteAll] and updated incrementally by [download].
  Set<int>? _onDiskCache;

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

  /// Single directory listing → parse `pNNN.woff` → set of page numbers.
  /// Replaces 604 sequential `File.exists()` calls (~200–500 ms on
  /// flash storage) with one streamed listing (~5–20 ms).
  Future<Set<int>> _scanOnDisk() async {
    if (_onDiskCache != null) return _onDiskCache!;
    final dir = await _dir();
    final pages = <int>{};
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (!name.startsWith('p') || !name.endsWith('.woff')) continue;
      final n = int.tryParse(name.substring(1, name.length - 5));
      if (n != null && n >= 1 && n <= _totalPages) pages.add(n);
    }
    _onDiskCache = pages;
    return pages;
  }

  @override
  Future<int> downloadedCount() async => (await _scanOnDisk()).length;

  @override
  Future<bool> isComplete() async =>
      (await _scanOnDisk()).length == _totalPages;

  @override
  Stream<int> download() async* {
    final dir = await _dir();
    final onDisk = await _scanOnDisk();
    yield onDisk.length;
    for (var i = 1; i <= _totalPages; i++) {
      if (onDisk.contains(i)) continue;
      final file = _file(dir, i);
      try {
        await _dio.download('$_baseUrl/p$i.woff', file.path);
        onDisk.add(i);
        yield onDisk.length;
      } catch (_) {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteAll() async {
    final dir = await _dir();
    if (await dir.exists()) await dir.delete(recursive: true);
    _cachedDir = null;
    _onDiskCache = null;
    // Note: `_registered` is intentionally NOT cleared. Flutter has no
    // unregister API; the registrations stay in engine memory until
    // process restart, so a fresh delete + re-download in the same
    // session would otherwise re-load fonts that are already live.
  }

  @override
  bool isFontRegistered(int pageNumber) => _registered.contains(pageNumber);

  @override
  Future<bool> ensureFontForPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > _totalPages) {
      return Future.value(false);
    }
    if (_registered.contains(pageNumber)) return Future.value(true);
    final pending = _inFlight[pageNumber];
    if (pending != null) return pending;
    final future = _loadFont(pageNumber);
    _inFlight[pageNumber] = future;
    future.whenComplete(() => _inFlight.remove(pageNumber));
    return future;
  }

  Future<bool> _loadFont(int pageNumber) async {
    final dir = await _dir();
    final file = _file(dir, pageNumber);
    if (!await file.exists()) {
      _onDiskCache?.remove(pageNumber);
      return false;
    }
    final bytes = await file.readAsBytes();
    final family = 'QCF_P${pageNumber.toString().padLeft(3, '0')}';
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
    _registered.add(pageNumber);
    _onDiskCache?.add(pageNumber);
    return true;
  }
}
