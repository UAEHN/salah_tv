import '../../../quran/domain/entities/quran_reciter.dart';

/// Section markers + reciter rows produced by [buildReciterPickerEntries].
sealed class ReciterPickerEntry {
  const ReciterPickerEntry();
}

class ReciterSectionHeader extends ReciterPickerEntry {
  final ReciterSection section;
  const ReciterSectionHeader(this.section);
}

class ReciterRow extends ReciterPickerEntry {
  final QuranApiReciter reciter;
  final bool isFavorite;
  const ReciterRow({required this.reciter, required this.isFavorite});
}

enum ReciterSection { favorites, all }

/// Builds the ordered entry list for the picker.
///
/// Behavior:
///   - When the search [query] is empty AND there is at least one favorite,
///     emit a "favorites" header followed by favorite rows (in the order
///     stored in settings), then an "all" header followed by the rest.
///   - Otherwise (searching, or no favorites), emit a flat list of rows
///     matching [query]. Favorites still get the star indicator.
///
/// Favorites are matched against the live reciter list — a starred reciter
/// missing from the API response is silently skipped (avoids dead rows).
List<ReciterPickerEntry> buildReciterPickerEntries({
  required List<QuranApiReciter> reciters,
  required List<String> favoriteUrls,
  required bool Function(String nameAr) matchesQuery,
  required bool isSearching,
}) {
  final favoriteSet = favoriteUrls.toSet();

  if (isSearching || favoriteUrls.isEmpty) {
    return [
      for (final r in reciters)
        if (matchesQuery(r.nameAr))
          ReciterRow(reciter: r, isFavorite: favoriteSet.contains(r.serverUrl)),
    ];
  }

  final byUrl = {for (final r in reciters) r.serverUrl: r};
  final favoriteRows = <ReciterRow>[
    for (final url in favoriteUrls)
      if (byUrl[url] != null)
        ReciterRow(reciter: byUrl[url]!, isFavorite: true),
  ];
  final otherRows = <ReciterRow>[
    for (final r in reciters)
      if (!favoriteSet.contains(r.serverUrl))
        ReciterRow(reciter: r, isFavorite: false),
  ];

  return [
    if (favoriteRows.isNotEmpty) ...[
      const ReciterSectionHeader(ReciterSection.favorites),
      ...favoriteRows,
    ],
    if (otherRows.isNotEmpty) ...[
      const ReciterSectionHeader(ReciterSection.all),
      ...otherRows,
    ],
  ];
}
