import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/detected_location.dart';

/// Detects the user's GPS location via reverse geocoding.
///
/// Returns a [DetectedLocation] that may or may not match a city in the
/// bundled SQLite prayer-time database. When [DetectedLocation.isInDb] is
/// false the app should fall back to astronomical calculation.
abstract class ILocationDetector {
  /// [locale] biases the native reverse geocoder (Apple Maps / Google
  /// Geocoder) toward returning placemark names in that language — pass
  /// the app's current locale (e.g. 'ar' or 'en') so detected city names
  /// match the UI language. Falls back to device default when null.
  Future<Either<Failure, DetectedLocation>> detectLocation({String? locale});
}
