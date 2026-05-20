import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/daily_verse.dart';
import '../domain/i_daily_verse_repository.dart';
import 'daily_verses_catalog.dart';

class DailyVerseRepositoryImpl implements IDailyVerseRepository {
  const DailyVerseRepositoryImpl();

  @override
  Future<Either<Failure, DailyVerse>> getVerseForDay(DateTime now) async {
    try {
      if (kDailyVersesCatalog.isEmpty) {
        return const Left(CacheFailure('empty verses catalog'));
      }
      final dayOfYear = _dayOfYear(now);
      final index = dayOfYear % kDailyVersesCatalog.length;
      return Right(kDailyVersesCatalog[index]);
    } on Object catch (e) {
      return Left(CacheFailure('daily verse error: $e'));
    }
  }

  /// 1-based day of year, robust across leap years.
  int _dayOfYear(DateTime now) {
    final start = DateTime(now.year, 1, 1);
    return now.difference(start).inDays + 1;
  }
}
