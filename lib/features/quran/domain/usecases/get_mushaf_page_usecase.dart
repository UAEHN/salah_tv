import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mushaf_page.dart';
import '../i_quran_text_repository.dart';

/// Reads a single Mushaf page through the text repository.
class GetMushafPageUseCase {
  final IQuranTextRepository _repo;
  const GetMushafPageUseCase(this._repo);

  Future<Either<Failure, MushafPage>> call(int pageNumber) =>
      _repo.getPage(pageNumber);
}
