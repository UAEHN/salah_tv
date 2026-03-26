import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/detected_location.dart';

/// Detects the user's GPS location via reverse geocoding.
///
/// Returns a [DetectedLocation] that may or may not match a city in the
/// bundled SQLite prayer-time database. When [DetectedLocation.isInDb] is
/// false the app should fall back to astronomical calculation.
abstract class ILocationDetector {
  Future<Either<Failure, DetectedLocation>> detectLocation();
}
