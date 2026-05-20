import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/daily_verse.dart';
import '../i_daily_verse_repository.dart';

class GetDailyVerseUseCase {
  final IDailyVerseRepository _repo;

  const GetDailyVerseUseCase(this._repo);

  Future<Either<Failure, DailyVerse>> call({DateTime? now}) {
    return _repo.getVerseForDay(now ?? DateTime.now());
  }
}
