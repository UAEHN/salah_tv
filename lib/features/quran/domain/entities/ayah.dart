/// A single Quranic verse with its position in the Mushaf and source surah.
///
/// Fields are derived from the bundled Tanzil Uthmani dataset and indexed
/// by [QuranPageIndexer]. `textUthmani` is the rendered Arabic text only —
/// the end-of-ayah marker (۝ + Arabic-Indic number) is added at render
/// time so the data stays free of presentation concerns.
class Ayah {
  final int surahNumber;
  final int numberInSurah;
  final int page;
  final int juz;
  final String textUthmani;

  /// True when this ayah is the first ayah of its surah on the page. Used
  /// by the renderer to know when to draw the surah banner before this
  /// ayah.
  final bool isFirstAyahOfSurah;

  /// One of "obligatory" / "recommended" when this ayah ends with a sajdah
  /// position; null otherwise.
  final String? sajdahType;

  /// 1..240 when this ayah marks the start of a rub-el-hizb quarter;
  /// null otherwise. `(quarterIndex - 1) ~/ 4 + 1` gives the hizb number.
  final int? quarterIndex;

  const Ayah({
    required this.surahNumber,
    required this.numberInSurah,
    required this.page,
    required this.juz,
    required this.textUthmani,
    required this.isFirstAyahOfSurah,
    this.sajdahType,
    this.quarterIndex,
  });

  bool get isSajdah => sajdahType != null;
  bool get isQuarterStart => quarterIndex != null;
}
