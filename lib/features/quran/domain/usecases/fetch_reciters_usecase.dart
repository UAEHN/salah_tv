import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/quran_reciter.dart';
import '../i_quran_api_repository.dart';

class FetchRecitersUseCase {
  final IQuranApiRepository _repo;

  FetchRecitersUseCase(this._repo);

  Future<Either<Failure, List<QuranApiReciter>>> call({String language = 'ar'}) =>
      _repo.fetchReciters(language: language);
}
