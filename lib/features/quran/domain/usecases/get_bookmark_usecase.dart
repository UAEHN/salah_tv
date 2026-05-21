import '../entities/quran_bookmark.dart';
import '../i_quran_bookmark_repository.dart';

class GetBookmarkUseCase {
  final IQuranBookmarkRepository _repo;
  const GetBookmarkUseCase(this._repo);

  Future<QuranBookmark?> call() => _repo.getBookmark();
}
