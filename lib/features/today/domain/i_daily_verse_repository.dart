import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/daily_verse.dart';

/// Read-only repository serving one [DailyVerse] per day of the year.
/// Implementations select deterministically from a bundled list so the
/// verse is identical across two devices on the same date.
abstract class IDailyVerseRepository {
  /// Returns the verse for the day of [now] (local time). `Left(Failure)`
  /// only when the bundled catalog cannot be loaded.
  Future<Either<Failure, DailyVerse>> getVerseForDay(DateTime now);
}
