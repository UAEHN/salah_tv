import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import '../domain/entities/ayah.dart';
import '../domain/entities/mushaf_page.dart';
import '../domain/i_quran_text_repository.dart';
import 'quran_page_indexer.dart';

/// Loads the bundled Uthmani Quran JSON once and serves Mushaf pages from
/// an in-memory map. The asset is large (~3-5MB) but loading happens off
/// the UI thread via `rootBundle.loadString` and the cost is paid only on
/// the first reader open.
class QuranTextRepository implements IQuranTextRepository {
  static const String _assetPath = 'assets/quran/quran_uthmani.json';
  static const QuranPageIndexer _indexer = QuranPageIndexer();

  Map<int, MushafPage>? _pages;
  Map<int, int>? _firstPageOfSurah;
  Map<int, int>?
  _nextAyahIndex; // key: surah*1000 + ayah → position in _allAyahs
  List<Ayah>? _allAyahs;
  Future<Either<Failure, Success>>? _inFlight;

  @override
  Future<Either<Failure, Success>> ensureLoaded() {
    if (_pages != null) return Future.value(const Right(Success()));
    return _inFlight ??= _load();
  }

  Future<Either<Failure, Success>> _load() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final pages = _indexer.indexFromJson(data);
      _pages = pages;
      _firstPageOfSurah = _buildSurahIndex(pages);
      _allAyahs = _buildAyahOrder(pages);
      _nextAyahIndex = _buildNextIndex(_allAyahs!);
      return const Right(Success());
    } catch (e) {
      debugPrint('[QuranText] load failed: $e');
      _inFlight = null;
      return Left(CacheFailure('Failed to load Quran text: $e'));
    }
  }

  Map<int, int> _buildSurahIndex(Map<int, MushafPage> pages) {
    final out = <int, int>{};
    final sortedKeys = pages.keys.toList()..sort();
    for (final p in sortedKeys) {
      for (final a in pages[p]!.ayahs) {
        out.putIfAbsent(a.surahNumber, () => p);
      }
    }
    return out;
  }

  List<Ayah> _buildAyahOrder(Map<int, MushafPage> pages) {
    final keys = pages.keys.toList()..sort();
    return [for (final p in keys) ...pages[p]!.ayahs];
  }

  Map<int, int> _buildNextIndex(List<Ayah> ayahs) {
    return {
      for (var i = 0; i < ayahs.length; i++)
        ayahs[i].surahNumber * 1000 + ayahs[i].numberInSurah: i,
    };
  }

  @override
  MushafPage? cachedPage(int pageNumber) => _pages?[pageNumber];

  @override
  Future<Either<Failure, MushafPage>> getPage(int pageNumber) async {
    final loaded = await ensureLoaded();
    return loaded.fold(Left.new, (_) {
      final page = _pages?[pageNumber];
      if (page == null) {
        return Left(CacheFailure('Page $pageNumber not found'));
      }
      return Right(page);
    });
  }

  @override
  Future<Either<Failure, int>> pageOfSurah(int surahNumber) async {
    final loaded = await ensureLoaded();
    return loaded.fold(Left.new, (_) {
      final page = _firstPageOfSurah?[surahNumber];
      if (page == null) {
        return Left(CacheFailure('Surah $surahNumber not indexed'));
      }
      return Right(page);
    });
  }

  @override
  Future<Ayah?> nextAyah(int surahNumber, int ayahNumber) async {
    final loaded = await ensureLoaded();
    if (loaded.isLeft()) return null;
    final idx = _nextAyahIndex?[surahNumber * 1000 + ayahNumber];
    if (idx == null) return null;
    final ayahs = _allAyahs;
    if (ayahs == null || idx + 1 >= ayahs.length) return null;
    return ayahs[idx + 1];
  }
}
