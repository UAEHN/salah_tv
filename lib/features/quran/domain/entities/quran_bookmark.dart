/// A saved reading position in the Mushaf.
///
/// Two flavours co-exist via [IQuranBookmarkRepository]:
/// - auto: rewritten every time the user leaves the reader.
/// - manual: rewritten only when the user taps the bookmark button. The
///   newer manual save replaces the previous one — a single-slot bookmark
///   by product decision.
class QuranBookmark {
  final int page;
  final int surahNumber;
  final int ayahNumber;
  final DateTime savedAt;

  const QuranBookmark({
    required this.page,
    required this.surahNumber,
    required this.ayahNumber,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'page': page,
    'surah': surahNumber,
    'ayah': ayahNumber,
    'savedAt': savedAt.toIso8601String(),
  };

  static QuranBookmark? fromJson(Map<String, dynamic> json) {
    final page = json['page'];
    final surah = json['surah'];
    final ayah = json['ayah'];
    final saved = json['savedAt'];
    if (page is! int || surah is! int || ayah is! int || saved is! String) {
      return null;
    }
    final dt = DateTime.tryParse(saved);
    if (dt == null) return null;
    return QuranBookmark(
      page: page,
      surahNumber: surah,
      ayahNumber: ayah,
      savedAt: dt,
    );
  }
}
