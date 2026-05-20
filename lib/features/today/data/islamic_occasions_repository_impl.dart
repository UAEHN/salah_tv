import 'package:dartz/dartz.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../core/error/failures.dart';
import '../domain/constants/today_constants.dart';
import '../domain/entities/upcoming_occasion.dart';
import '../domain/i_islamic_occasions_repository.dart';
import 'islamic_occasions_catalog.dart';

class IslamicOccasionsRepositoryImpl implements IIslamicOccasionsRepository {
  const IslamicOccasionsRepositoryImpl();

  @override
  Future<Either<Failure, UpcomingOccasion?>> getNextOccasion(
    DateTime from,
  ) async {
    try {
      final localFrom = DateTime(from.year, from.month, from.day);
      // Walk day-by-day up to the configured window. For each Gregorian day
      // compute its Hijri counterpart and look it up in the catalog. We
      // intentionally avoid the inverse direction (Hijri → Gregorian) because
      // the `hijri` package's reverse calendar can drift across implementations
      // — Gregorian-driven walking guarantees we honour the device's Hijri
      // anchor and stays correct around month boundaries.
      for (var offset = 0; offset <= kUpcomingOccasionWindowDays; offset++) {
        final candidate = localFrom.add(Duration(days: offset));
        final hijri = HijriCalendar.fromDate(candidate);
        final match = _findCatalogMatch(hijri.hMonth, hijri.hDay);
        if (match != null) {
          return Right(match.copyWithDaysUntil(offset));
        }
      }
      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure('occasions lookup error: $e'));
    }
  }

  UpcomingOccasion? _findCatalogMatch(int hMonth, int hDay) {
    for (final occasion in kIslamicOccasionsCatalog) {
      if (occasion.hijriMonth == hMonth && occasion.hijriDay == hDay) {
        return occasion;
      }
    }
    return null;
  }
}
