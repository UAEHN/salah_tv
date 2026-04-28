import '../../../../core/arabic_search.dart';
import '../../../quran/domain/entities/surah.dart';

/// Filters [surahs] by [query] using normalized Arabic matching. An empty
/// query returns the original list unmodified. A numeric query (e.g. "2")
/// also matches the surah whose number equals it.
List<Surah> filterSurahsByQuery(List<Surah> surahs, String query) {
  final q = normalizeArabicForSearch(query);
  if (q.isEmpty) return surahs;
  final asNumber = int.tryParse(query.trim());
  return surahs.where((s) {
    if (asNumber != null && s.number == asNumber) return true;
    return normalizeArabicForSearch(s.nameAr).contains(q);
  }).toList(growable: false);
}
