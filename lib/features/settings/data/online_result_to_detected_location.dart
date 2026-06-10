import 'package:geocoding/geocoding.dart';

import '../domain/entities/detected_location.dart';
import '../domain/entities/online_geocoding_result.dart';
import '../domain/entities/world_city.dart';
import '../domain/i_world_city_repository.dart';
import 'location_city_matcher.dart';
import 'location_country_matcher.dart';

/// Converts a Nominatim pick into a [DetectedLocation] by reusing the same
/// matching pipeline that GPS auto-detect runs: [LocationCountryMatcher] →
/// [LocationCityMatcher] (specific→broad with aliases) → nearest world-city
/// fallback via [IWorldCityRepository.resolveDetectedCity].
///
/// Mapping rule for accurate matching (mirrors native `Placemark`):
/// - `r.name`               → `placemark.locality`           (city/town)
/// - `r.subLocality`        → `placemark.subLocality`        (suburb)
/// - `r.subAdministrativeArea` → `placemark.subAdministrativeArea` (county)
/// - `r.administrativeArea` → `placemark.administrativeArea` (state/emirate)
/// - `r.countryName`        → `placemark.country`
/// - `r.countryCode`        → `placemark.isoCountryCode`
///
/// This means once the user picks "خور فكان" from search, the matcher sees
/// `locality="خور فكان"` first (specific) and resolves to the bundled
/// `Khor Fakkan` DB city via [kDbCityAliases] — exactly like GPS would
/// when standing in Khor Fakkan.
Future<DetectedLocation> detectedLocationFromOnlineResult(
  OnlineGeocodingResult r, {
  IWorldCityRepository? worldRepo,
  LocationCountryMatcher? countryMatcher,
  LocationCityMatcher? cityMatcher,
}) async {
  final cm = countryMatcher ?? LocationCountryMatcher();
  final cityM = cityMatcher ?? LocationCityMatcher();

  final placemark = _placemarkFor(r);
  final placemarks = [placemark];

  final countryResult = cm.match(
    isoCode: r.countryCode,
    names: [
      if (r.countryName != null && r.countryName!.trim().isNotEmpty)
        r.countryName!,
    ],
  );

  final dbCountryKey = countryResult?.dbKey;
  String? dbCityKey;
  if (dbCountryKey != null) {
    dbCityKey = cityM.match(dbCountryKey, placemarks);
  }

  WorldCity? resolvedWorldCity;
  if (dbCityKey == null && worldRepo != null && r.countryCode.isNotEmpty) {
    await worldRepo.initialize();
    resolvedWorldCity = worldRepo.resolveDetectedCity(
      countryKey: r.countryCode,
      cityName: r.name,
      latitude: r.latitude,
      longitude: r.longitude,
    );
  }

  return DetectedLocation(
    countryName:
        countryResult?.displayName ??
        r.countryName ??
        (r.countryCode.isNotEmpty ? r.countryCode : 'Unknown'),
    cityName: dbCityKey ?? r.name,
    latitude: r.latitude,
    longitude: r.longitude,
    isoCountryCode: r.countryCode.isEmpty ? null : r.countryCode,
    dbCountryKey: dbCityKey != null ? dbCountryKey : null,
    dbCityKey: dbCityKey,
    calculationMethod: resolvedWorldCity?.calculationMethod,
    timeZoneId: resolvedWorldCity?.timeZoneId,
    utcOffsetHours: resolvedWorldCity?.utcOffset,
  );
}

Placemark _placemarkFor(OnlineGeocodingResult r) {
  return Placemark(
    name: r.name,
    locality: r.name,
    subLocality: r.subLocality,
    administrativeArea: r.administrativeArea,
    subAdministrativeArea: r.subAdministrativeArea,
    country: r.countryName,
    isoCountryCode: r.countryCode.isEmpty ? null : r.countryCode,
  );
}
