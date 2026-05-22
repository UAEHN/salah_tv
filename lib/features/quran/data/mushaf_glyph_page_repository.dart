import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/mushaf_glyph_page.dart';
import '../domain/i_mushaf_glyph_page_repository.dart';

/// Loads per-page Mushaf v1 data (line layout + word codepoints) from
/// the bundled asset and registers each page's TTF with `FontLoader`
/// the first time we render it. Cached in-memory so a re-open is free.
class MushafGlyphPageRepository implements IMushafGlyphPageRepository {
  static const String _dataDir = 'assets/quran/pages_v1';
  static const String _fontDir = 'assets/fonts/QuranPagesV1';

  final Map<int, MushafGlyphPage> _pageCache = {};
  final Set<int> _fontsLoaded = {};
  final Map<int, Future<MushafGlyphPage>> _inFlight = {};

  @override
  MushafGlyphPage? cachedPage(int pageNumber) {
    // Both the JSON data and the page font must already be in memory —
    // a cached layout without its TTF would render boxes/tofu instead
    // of glyphs, defeating the point of skipping the spinner.
    if (!_fontsLoaded.contains(pageNumber)) return null;
    return _pageCache[pageNumber];
  }

  @override
  Future<bool> hasPage(int pageNumber) async {
    try {
      await rootBundle.load('$_dataDir/p$pageNumber.json');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<Failure, MushafGlyphPage>> getPage(int pageNumber) async {
    try {
      final cached = _pageCache[pageNumber];
      if (cached != null) {
        await _ensureFontLoaded(pageNumber);
        return Right(cached);
      }
      final future =
          _inFlight[pageNumber] ??= _loadPage(pageNumber).whenComplete(() {
        _inFlight.remove(pageNumber);
      });
      final page = await future;
      await _ensureFontLoaded(pageNumber);
      return Right(page);
    } catch (e) {
      debugPrint('[MushafGlyphRepo] page $pageNumber failed: $e');
      return Left(CacheFailure('Page $pageNumber unavailable: $e'));
    }
  }

  Future<MushafGlyphPage> _loadPage(int pageNumber) async {
    final raw = await rootBundle.loadString('$_dataDir/p$pageNumber.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final linesRaw = data['lines'] as Map<String, dynamic>;
    final lines = linesRaw.entries
        .map((e) => _decodeLine(int.parse(e.key), e.value as List))
        .toList()
      ..sort((a, b) => a.lineNumber.compareTo(b.lineNumber));
    final page = MushafGlyphPage(pageNumber: pageNumber, lines: lines);
    _pageCache[pageNumber] = page;
    return page;
  }

  MushafGlyphLine _decodeLine(int lineNumber, List rawWords) {
    final words = [
      for (final w in rawWords)
        MushafGlyphWord(
          code: (w as Map)['c'] as String,
          charType: w['t'] as String,
          verseKey: w['k'] as String,
          verseNumber: (w['v'] as num).toInt(),
        ),
    ];
    return MushafGlyphLine(lineNumber: lineNumber, words: words);
  }

  // Each page has its own TTF; we register it under family `QPCV1_P{N}`
  // (matches MushafGlyphPage.fontFamily). FontLoader.load() is idempotent
  // but we guard with _fontsLoaded so we don't re-fetch the byte buffer.
  Future<void> _ensureFontLoaded(int pageNumber) async {
    if (_fontsLoaded.contains(pageNumber)) return;
    final family = 'QPCV1_P$pageNumber';
    final loader = FontLoader(family);
    loader.addFont(rootBundle.load('$_fontDir/p$pageNumber.ttf'));
    await loader.load();
    _fontsLoaded.add(pageNumber);
  }
}
