/// Per-page Mushaf rendering model (the "v1" system used by quran.com).
///
/// Each printed Madinah Mushaf page has its own dedicated font file
/// (`p1.ttf` … `p604.ttf`). The font contains one glyph per word on the
/// page, mapped to a Private Use Area codepoint. Rendering a page = pick
/// the page font, then draw every line's words in order using their
/// codepoints. This gives **pixel-identical** layout to the printed
/// Mushaf — every line break, every word position, every Quranic mark
/// matches the official Madinah Mushaf.
library;

/// One word on a Mushaf page line.
class MushafGlyphWord {
  /// Single PUA codepoint that the page font renders as the word's
  /// calligraphic glyph (e.g. `ﭑ` → بِسۡمِ).
  final String code;

  /// `'word'` for normal words, `'end'` for the rosette that holds the
  /// ayah number at the end of a verse.
  final String charType;

  /// Verse key in `surah:ayah` form (e.g. `"2:255"`). Used to map tap
  /// targets back to the existing per-ayah audio / bookmark flows.
  final String verseKey;

  /// 1-based verse number within the surah.
  final int verseNumber;

  const MushafGlyphWord({
    required this.code,
    required this.charType,
    required this.verseKey,
    required this.verseNumber,
  });

  bool get isEndOfAyah => charType == 'end';
}

/// One physical line on a Mushaf page (the Madinah Mushaf uses 15 lines
/// for body pages; pages 1–2 have fewer because of the surah-frame
/// decoration at the top).
class MushafGlyphLine {
  /// 1-based line number on the page (1..15).
  final int lineNumber;
  final List<MushafGlyphWord> words;

  const MushafGlyphLine({required this.lineNumber, required this.words});
}

/// One full Mushaf page in the v1 system.
class MushafGlyphPage {
  /// 1..604.
  final int pageNumber;
  final List<MushafGlyphLine> lines;

  const MushafGlyphPage({required this.pageNumber, required this.lines});

  /// Font family that must be loaded (and registered) before rendering
  /// this page. Maps 1:1 to the asset `assets/fonts/QuranPagesV1/p{N}.ttf`.
  String get fontFamily => 'QPCV1_P$pageNumber';
}
