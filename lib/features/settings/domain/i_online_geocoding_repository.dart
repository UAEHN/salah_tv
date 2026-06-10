import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/online_geocoding_result.dart';

/// Searches the open internet for any city/place worldwide. Used when the
/// bundled `world_cities.json` catalog does not contain the user's location
/// — solves the «my city isn't on the list» churn problem.
abstract class IOnlineGeocodingRepository {
  /// [countryCode] (ISO-2) biases Nominatim to a single country — used by
  /// the city-level picker after a country is selected so users can find any
  /// town inside that country, even if it's missing from the bundled lists.
  Future<Either<Failure, List<OnlineGeocodingResult>>> search(
    String query, {
    String? countryCode,
  });

  /// Reverse-geocode coordinates → place. Used by GPS auto-detect so the
  /// detector pipeline matches manual search exactly (same data source,
  /// same address structure). Returns `null` only when Nominatim has no
  /// result for the coordinates — never throws for normal "no match".
  Future<Either<Failure, OnlineGeocodingResult?>> reverse({
    required double latitude,
    required double longitude,
    String? localeHint,
  });
}
