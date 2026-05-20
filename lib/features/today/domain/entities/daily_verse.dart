/// A single verse surfaced on the "Today" screen, picked deterministically
/// from a curated list (one verse per day-of-year).
class DailyVerse {
  /// Surah number [1..114].
  final int surahNumber;

  /// Ayah number within the surah.
  final int ayahNumber;

  /// Arabic text (with diacritics).
  final String textAr;

  /// Localization key for the surah's display name (e.g. `'surahFatiha'`).
  /// Optional — empty string falls back to a numeric label.
  final String surahLabelKey;

  const DailyVerse({
    required this.surahNumber,
    required this.ayahNumber,
    required this.textAr,
    this.surahLabelKey = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyVerse &&
          other.surahNumber == surahNumber &&
          other.ayahNumber == ayahNumber &&
          other.textAr == textAr;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber, textAr);
}
