import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/i_page_image_repository.dart';
import 'quran_page_image_urls.dart';

/// Persists every Madinah Mushaf page PNG in
/// `{appDocs}/quran_pages/p{NNN}.png`. The documents directory
/// survives OS cache eviction, so a Mushaf that's been fully
/// pre-fetched stays usable offline indefinitely.
///
/// Per-page download is coalesced (the reader's `PageView.builder`
/// fires the same page's `FutureBuilder` twice in some swipe
/// directions) and the on-disk inventory is cached after the first
/// directory listing so subsequent page-flips don't pay another
/// `Directory.list()` cost.
class QuranPageImageRepository implements IPageImageRepository {
  static const int _total = 604;
  static const String _dirName = 'quran_pages';

  final Dio _dio;
  Directory? _cachedDir;
  Set<int>? _onDiskCache;
  final Map<int, Future<String>> _inFlight = <int, Future<String>>{};

  QuranPageImageRepository(this._dio);

  @override
  int get totalPages => _total;

  Future<Directory> _dir() async {
    if (_cachedDir != null) return _cachedDir!;
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_dirName');
    if (!await dir.exists()) await dir.create(recursive: true);
    _cachedDir = dir;
    return dir;
  }

  String _filename(int pageNumber) =>
      'p${pageNumber.toString().padLeft(3, '0')}.png';

  File _file(Directory dir, int pageNumber) =>
      File('${dir.path}/${_filename(pageNumber)}');

  /// Single directory listing → parse `pNNN.png` → set of page numbers.
  /// Replaces 604 sequential `File.exists()` calls.
  Future<Set<int>> _scanOnDisk() async {
    if (_onDiskCache != null) return _onDiskCache!;
    final dir = await _dir();
    final pages = <int>{};
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (!name.startsWith('p') || !name.endsWith('.png')) continue;
      final n = int.tryParse(name.substring(1, name.length - 4));
      if (n != null && n >= 1 && n <= _total) pages.add(n);
    }
    _onDiskCache = pages;
    return pages;
  }

  @override
  Future<int> downloadedCount() async => (await _scanOnDisk()).length;

  @override
  Future<bool> isComplete() async => (await _scanOnDisk()).length == _total;

  @override
  Future<String> ensurePage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > _total) {
      return Future.error(ArgumentError('Invalid page number: $pageNumber'));
    }
    final pending = _inFlight[pageNumber];
    if (pending != null) return pending;
    final future = _resolvePage(pageNumber);
    _inFlight[pageNumber] = future;
    future.whenComplete(() => _inFlight.remove(pageNumber));
    return future;
  }

  Future<String> _resolvePage(int pageNumber) async {
    final dir = await _dir();
    final file = _file(dir, pageNumber);
    if (await file.exists()) {
      _onDiskCache?.add(pageNumber);
      return file.path;
    }
    final url = QuranPageImageUrls.forPage(pageNumber);
    await _dio.download(url, file.path);
    _onDiskCache?.add(pageNumber);
    return file.path;
  }

  @override
  Future<void> deleteAll() async {
    final dir = await _dir();
    if (await dir.exists()) await dir.delete(recursive: true);
    _cachedDir = null;
    _onDiskCache = null;
  }

  @override
  Stream<int> downloadAll() async* {
    final dir = await _dir();
    final onDisk = await _scanOnDisk();
    yield onDisk.length;
    for (var i = 1; i <= _total; i++) {
      if (onDisk.contains(i)) continue;
      final file = _file(dir, i);
      final url = QuranPageImageUrls.forPage(i);
      await _dio.download(url, file.path);
      onDisk.add(i);
      yield onDisk.length;
    }
  }
}
