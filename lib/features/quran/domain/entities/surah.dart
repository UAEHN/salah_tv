/// Quranic surah metadata.
class Surah {
  /// 1-based surah number (1..114).
  final int number;

  /// Arabic name with definite article, e.g. "البقرة".
  final String nameAr;

  /// Total number of ayahs in the surah.
  final int ayahCount;

  const Surah({
    required this.number,
    required this.nameAr,
    required this.ayahCount,
  });
}
