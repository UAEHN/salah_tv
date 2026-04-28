/// Normalizes Arabic text for forgiving search matching:
///   • Strips diacritics (تشكيل) so "البَقَرة" matches "البقرة".
///   • Unifies alef variants (أ إ آ) → ا and tāʾ marbūṭa (ة) → ه so "بقره"
///     matches "بقرة".
///   • Drops a leading "ال" article so "بقرة" matches "البقرة".
///   • Lower-cases ASCII so an English fallback ("baqarah") works too.
String normalizeArabicForSearch(String input) {
  if (input.isEmpty) return '';
  final stripped = input.replaceAll(RegExp(r'[ً-ْٰ]'), '');
  final unified = stripped
      .replaceAll(RegExp(r'[أإآ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه');
  final trimmed = unified.trim();
  final noArticle = trimmed.startsWith('ال') && trimmed.length > 2
      ? trimmed.substring(2)
      : trimmed;
  return noArticle.toLowerCase();
}
