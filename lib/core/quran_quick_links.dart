/// Quick-access shortcut shown as a chip in the Quran-tab landing
/// page. Two flavours:
///   * **Single ayah** (e.g. آية الكرسي) — `ayah` is non-null. The
///     reader navigates to the ayah's page and flashes a highlight
///     overlay on that single verse for ~2 seconds.
///   * **Whole surah** (e.g. الكهف, الملك) — `ayah` is null. The
///     reader jumps to the surah's first page; no flash overlay.
class QuranQuickLink {
  /// Stable key resolved to a localized label via
  /// `quranQuickLinkLabel` — the chip text follows the app language.
  final String labelKey;
  final int surah;
  final int? ayah;

  const QuranQuickLink({
    required this.labelKey,
    required this.surah,
    this.ayah,
  });

  bool get isWholeSurah => ayah == null;
}

const List<QuranQuickLink> kQuranQuickLinks = [
  QuranQuickLink(labelKey: 'ayatAlKursi', surah: 2, ayah: 255),
  QuranQuickLink(labelKey: 'surahKahf', surah: 18),
  QuranQuickLink(labelKey: 'surahYaseen', surah: 36),
  QuranQuickLink(labelKey: 'surahRahman', surah: 55),
  QuranQuickLink(labelKey: 'surahWaqiah', surah: 56),
  QuranQuickLink(labelKey: 'surahMulk', surah: 67),
];
