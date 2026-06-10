/// Quick-access shortcut shown as a chip in the Quran-tab landing
/// page. Two flavours:
///   * **Single ayah** (e.g. آية الكرسي) — `ayah` is non-null. The
///     reader navigates to the ayah's page and flashes a highlight
///     overlay on that single verse for ~2 seconds.
///   * **Whole surah** (e.g. الكهف, الملك) — `ayah` is null. The
///     reader jumps to the surah's first page; no flash overlay.
class QuranQuickLink {
  final String label;
  final int surah;
  final int? ayah;

  const QuranQuickLink({required this.label, required this.surah, this.ayah});

  bool get isWholeSurah => ayah == null;
}

const List<QuranQuickLink> kQuranQuickLinks = [
  QuranQuickLink(label: 'آية الكرسي', surah: 2, ayah: 255),
  QuranQuickLink(label: 'سورة الكهف', surah: 18),
  QuranQuickLink(label: 'سورة يس', surah: 36),
  QuranQuickLink(label: 'سورة الرحمن', surah: 55),
  QuranQuickLink(label: 'سورة الواقعة', surah: 56),
  QuranQuickLink(label: 'سورة الملك', surah: 67),
];
