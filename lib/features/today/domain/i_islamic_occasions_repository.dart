import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/upcoming_occasion.dart';

/// Read-only catalog of well-known Hijri occasions (Ramadan, Arafah, Eid…).
/// Pure data — no remote calls, no side effects.
abstract class IIslamicOccasionsRepository {
  /// Returns the next [UpcomingOccasion] within the lookup window starting
  /// from [from] (a UTC `DateTime`). `Right(null)` when nothing matches.
  Future<Either<Failure, UpcomingOccasion?>> getNextOccasion(DateTime from);
}
