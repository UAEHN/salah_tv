import 'package:ghasaq/l10n/app_localizations.dart';

/// Maps a [QuranQuickLink.labelKey] to its localized chip label so the
/// Quran-tab shortcuts follow the app language (§10). Unknown keys fall
/// back to the key itself rather than crashing.
String quranQuickLinkLabel(AppLocalizations l, String labelKey) {
  return switch (labelKey) {
    'ayatAlKursi' => l.mushafQuickAyatAlKursi,
    'surahKahf' => l.mushafQuickSurahKahf,
    'surahYaseen' => l.mushafQuickSurahYaseen,
    'surahRahman' => l.mushafQuickSurahRahman,
    'surahWaqiah' => l.mushafQuickSurahWaqiah,
    'surahMulk' => l.mushafQuickSurahMulk,
    _ => labelKey,
  };
}
