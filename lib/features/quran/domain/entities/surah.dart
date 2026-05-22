/// Where the surah was revealed. Mushafs traditionally mark this distinction
/// because Makki surahs (revealed before the Hijra) and Madani surahs
/// (revealed after) have different stylistic and thematic patterns.
enum RevelationType { makki, madani }

/// Quranic surah metadata.
class Surah {
  /// 1-based surah number (1..114).
  final int number;

  /// Arabic name with definite article, e.g. "البقرة".
  final String nameAr;

  /// Latin transliteration commonly used in English Quran apps,
  /// e.g. "Al-Baqarah". Sourced from quran.com / IslamicFinder.
  final String nameEn;

  /// Total number of ayahs in the surah.
  final int ayahCount;

  /// Where the surah was revealed (Makkah vs Madinah).
  final RevelationType revelation;

  /// First Mushaf page (1..604) on which this surah starts.
  final int firstPage;

  const Surah({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.ayahCount,
    required this.revelation,
    required this.firstPage,
  });

  /// Returns the surah name for the given locale language code
  /// (`'ar'` → Arabic, anything else → English transliteration).
  String localizedName(String localeCode) =>
      localeCode == 'ar' ? nameAr : nameEn;
}
