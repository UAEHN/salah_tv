import 'package:flutter/widgets.dart';

/// Convert a Latin-digit integer to Arabic-Indic digits. Used for the
/// end-of-ayah marker (always Arabic-Indic regardless of locale) and as
/// the Arabic branch of [digitsForLocale].
String toArabicIndic(int n) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  if (n < 0) return n.toString();
  if (n == 0) return digits[0];
  final buf = StringBuffer();
  for (final ch in n.toString().split('')) {
    final d = int.tryParse(ch);
    buf.write(d == null ? ch : digits[d]);
  }
  return buf.toString();
}

/// Locale-aware digit formatter for UI chrome (page, juz, surah, count).
/// Arabic locale → Arabic-Indic, anything else → Latin digits.
/// Ayah numbers should NOT use this — they always stay Arabic-Indic.
String digitsForLocale(BuildContext context, int n) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  return isArabic ? toArabicIndic(n) : n.toString();
}
