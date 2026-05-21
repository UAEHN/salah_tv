import '../entities/quran_bookmark.dart';
import '../i_quran_bookmark_repository.dart';

/// Persists the current reading position to the single bookmark slot.
/// Used by both the explicit save button and the auto-save-on-leave flow.
class SaveBookmarkUseCase {
  final IQuranBookmarkRepository _repo;
  const SaveBookmarkUseCase(this._repo);

  Future<void> call(QuranBookmark bookmark) => _repo.saveBookmark(bookmark);
}
