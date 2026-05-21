import 'entities/quran_bookmark.dart';

/// Single-slot bookmark store for the Mushaf reader.
///
/// Both flows that "save where I am" — the explicit save button in the
/// reader and the automatic save when the user leaves the reader — write
/// to the same slot. The newer save replaces the older one.
abstract class IQuranBookmarkRepository {
  Future<QuranBookmark?> getBookmark();
  Future<void> saveBookmark(QuranBookmark bookmark);
}
