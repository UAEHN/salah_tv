import 'ayah.dart';

/// One page of the standard 604-page Madani Mushaf.
///
/// `ayahs` is the ordered list of verses that appear on the page (across one
/// or more surahs). `juz` is the juz number of the first ayah on the page.
/// Surah banners are derived from `ayahs.where((a) => a.isFirstAyahOfSurah)`
/// at render time — we don't precompute banner positions to keep the entity
/// tiny.
class MushafPage {
  /// 1-based page number (1..604).
  final int pageNumber;
  final int juz;
  final List<Ayah> ayahs;

  const MushafPage({
    required this.pageNumber,
    required this.juz,
    required this.ayahs,
  });

  /// Total number of pages in the standard Madani Mushaf.
  static const int totalPages = 604;
}
