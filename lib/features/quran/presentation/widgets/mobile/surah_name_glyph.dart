/// Helpers for the `SurahNames` font (from quran.com-frontend-next).
///
/// The font uses OpenType ligatures: a 3-digit zero-padded chapter id
/// (e.g. "001", "036", "114") collapses into a single calligraphic
/// medallion glyph for that surah. The literal token "surah" renders
/// the decorative standalone word سورة.
library;

/// Returns the 3-digit zero-padded chapter id for [number]. When drawn
/// with `fontFamily: 'SurahNames'`, the digits collapse into one
/// calligraphic surah-name medallion via the font's GSUB ligatures.
/// Returns an empty string for out-of-range numbers.
String surahNameLigatureToken(int number) {
  if (number < 1 || number > 114) return '';
  return number.toString().padLeft(3, '0');
}

/// Literal token that renders the decorative standalone word سورة when
/// drawn with the `SurahNames` font family.
const String surahWordLigatureToken = 'surah';
