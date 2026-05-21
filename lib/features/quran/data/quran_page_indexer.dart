import '../domain/entities/ayah.dart';
import '../domain/entities/mushaf_page.dart';

/// Converts the flat JSON list shipped under `assets/quran/quran_uthmani.json`
/// into a `Map<int, MushafPage>` keyed by page number.
///
/// Expected JSON shape (top-level keys flexible; we look up `ayahs`):
/// ```
/// {
///   "ayahs": [
///     { "surah": 1, "ayah": 1, "page": 1, "juz": 1, "text": "بِسْمِ ٱللَّهِ ..." },
///     ...
///   ]
/// }
/// ```
/// Per-ayah `isFirstAyahOfSurah` is derived here (true when `ayah == 1`).
class QuranPageIndexer {
  const QuranPageIndexer();

  Map<int, MushafPage> indexFromJson(Map<String, dynamic> json) {
    final raw = json['ayahs'];
    if (raw is! List) {
      throw const FormatException('quran_uthmani.json: missing "ayahs" array');
    }
    final byPage = <int, List<Ayah>>{};
    final juzByPage = <int, int>{};
    for (final entry in raw) {
      if (entry is! Map) continue;
      final ayah = _parseAyah(entry.cast<String, dynamic>());
      if (ayah == null) continue;
      (byPage[ayah.page] ??= []).add(ayah);
      juzByPage.putIfAbsent(ayah.page, () => ayah.juz);
    }
    return {
      for (final entry in byPage.entries)
        entry.key: MushafPage(
          pageNumber: entry.key,
          juz: juzByPage[entry.key] ?? 1,
          ayahs: List.unmodifiable(entry.value),
        ),
    };
  }

  Ayah? _parseAyah(Map<String, dynamic> m) {
    final surah = m['surah'];
    final ayah = m['ayah'];
    final page = m['page'];
    final juz = m['juz'];
    final text = m['text'];
    if (surah is! int ||
        ayah is! int ||
        page is! int ||
        juz is! int ||
        text is! String) {
      return null;
    }
    final sajdah = m['sajdah'];
    final quarter = m['quarter'];
    return Ayah(
      surahNumber: surah,
      numberInSurah: ayah,
      page: page,
      juz: juz,
      textUthmani: text,
      isFirstAyahOfSurah: ayah == 1,
      sajdahType: sajdah is String ? sajdah : null,
      quarterIndex: quarter is int ? quarter : null,
    );
  }
}
