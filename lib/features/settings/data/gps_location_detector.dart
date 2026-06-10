import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/world_city.dart';
import '../domain/entities/detected_location.dart';
import '../domain/i_location_detector.dart';
import '../domain/i_online_geocoding_repository.dart';
import '../domain/i_world_city_repository.dart';
import 'location_city_matcher.dart';
import 'location_country_matcher.dart';
import 'online_result_to_detected_location.dart';

/// GPS-based location detector that works worldwide.
///
/// Reverse-geocoding strategy (in order):
///   1. Nominatim (OpenStreetMap) — primary. Matches manual search exactly,
///      and covers small towns the native geocoder misses (Al Bidyah,
///      Madinat Zayed, etc.).
///   2. Native [placemarkFromCoordinates] — fallback when Nominatim is
///      unreachable (no internet, rate-limit, …).
///   3. Clean [LocationFailure] when both fail — never emits "Unknown".
class GpsLocationDetector implements ILocationDetector {
  static const _cachedPositionMaxAge = Duration(minutes: 30);
  static const _cachedPositionMaxAccuracyMeters = 15000.0;

  GpsLocationDetector({
    LocationCountryMatcher? countryMatcher,
    LocationCityMatcher? cityMatcher,
    IWorldCityRepository? worldCityRepository,
    IOnlineGeocodingRepository? onlineGeocodingRepository,
  }) : _countryMatcher = countryMatcher ?? LocationCountryMatcher(),
       _cityMatcher = cityMatcher ?? LocationCityMatcher(),
       _worldCityRepository = worldCityRepository,
       _onlineGeocodingRepository = onlineGeocodingRepository;

  final LocationCountryMatcher _countryMatcher;
  final LocationCityMatcher _cityMatcher;
  final IWorldCityRepository? _worldCityRepository;
  final IOnlineGeocodingRepository? _onlineGeocodingRepository;

  Future<Either<Failure, DetectedLocation>>? _activeDetection;

  @override
  Future<Either<Failure, DetectedLocation>> detectLocation({String? locale}) {
    final activeDetection = _activeDetection;
    if (activeDetection != null) return activeDetection;

    final detection = _detectLocation(locale: locale);
    _activeDetection = detection;
    detection.whenComplete(() {
      if (identical(_activeDetection, detection)) {
        _activeDetection = null;
      }
    });
    return detection;
  }

  Future<Either<Failure, DetectedLocation>> _detectLocation({
    String? locale,
  }) async {
    final failure = await _ensurePermission();
    if (failure != null) return Left(failure);

    final position = await _resolvePosition();
    if (position == null) {
      return const Left(LocationFailure('Unable to determine location'));
    }

    // Primary path — Nominatim reverse. Same data source as manual search,
    // so GPS produces identical results to typing the city name.
    final nominatim = await _tryNominatimReverse(position, locale: locale);
    if (nominatim != null) return Right(nominatim);

    // Fallback — native reverse geocoder. May produce "Unknown" for small
    // places the OS doesn't know; still better than a hard failure.
    return _detectViaNativeGeocoder(position, locale: locale);
  }

  Future<DetectedLocation?> _tryNominatimReverse(
    Position position, {
    String? locale,
  }) async {
    final repo = _onlineGeocodingRepository;
    if (repo == null) return null;
    final result = await repo.reverse(
      latitude: position.latitude,
      longitude: position.longitude,
      localeHint: locale,
    );
    final place = result.fold((_) => null, (p) => p);
    if (place == null) return null;
    return detectedLocationFromOnlineResult(
      place,
      worldRepo: _worldCityRepository,
      countryMatcher: _countryMatcher,
      cityMatcher: _cityMatcher,
    );
  }

  Future<Either<Failure, DetectedLocation>> _detectViaNativeGeocoder(
    Position position, {
    String? locale,
  }) async {
    final placemarks = await _reverseGeocode(position, locale: locale);
    if (placemarks.isEmpty) {
      return const Left(LocationFailure('Unable to read location details'));
    }

    final countryResult = _countryMatcher.match(
      isoCode: placemarks.first.isoCountryCode,
      names: placemarks.map((p) => p.country ?? ''),
    );

    String? dbCountryKey = countryResult?.dbKey;
    String? dbCityKey;
    WorldCity? resolvedWorldCity;
    if (dbCountryKey != null) {
      dbCityKey = _cityMatcher.match(dbCountryKey, placemarks);
    }

    final countryDisplay =
        countryResult?.displayName ?? placemarks.first.country ?? 'Unknown';
    final cityDisplay = _bestCityName(placemarks) ?? 'Unknown';
    if (dbCityKey == null) {
      resolvedWorldCity = await _resolveWorldCity(
        isoCountryCode: placemarks.first.isoCountryCode,
        cityName: cityDisplay,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }

    return Right(
      DetectedLocation(
        countryName: countryDisplay,
        cityName: dbCityKey ?? cityDisplay,
        latitude: position.latitude,
        longitude: position.longitude,
        isoCountryCode: placemarks.first.isoCountryCode,
        dbCountryKey: dbCityKey != null ? dbCountryKey : null,
        dbCityKey: dbCityKey,
        calculationMethod: resolvedWorldCity?.calculationMethod,
        timeZoneId: resolvedWorldCity?.timeZoneId,
        utcOffsetHours: resolvedWorldCity?.utcOffset,
      ),
    );
  }

  Future<WorldCity?> _resolveWorldCity({
    required String? isoCountryCode,
    required String cityName,
    required double latitude,
    required double longitude,
  }) async {
    final repo = _worldCityRepository;
    final countryKey = isoCountryCode?.trim().toUpperCase();
    if (repo == null || countryKey == null || countryKey.isEmpty) return null;
    await repo.initialize();
    return repo.resolveDetectedCity(
      countryKey: countryKey,
      cityName: cityName,
      latitude: latitude,
      longitude: longitude,
    );
  }

  String? _bestCityName(List<Placemark> placemarks) {
    for (final p in placemarks.take(3)) {
      final candidate =
          p.locality ?? p.subAdministrativeArea ?? p.administrativeArea;
      if (candidate != null && candidate.trim().isNotEmpty) return candidate;
    }
    return null;
  }

  Future<List<Placemark>> _reverseGeocode(
    Position position, {
    String? locale,
  }) async {
    try {
      if (locale != null && locale.isNotEmpty) {
        // Bias native geocoder (Apple/Google) toward the app's language.
        // No-op if the platform doesn't recognize the identifier.
        await setLocaleIdentifier(locale);
      }
      return placemarkFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('[Location] reverse geocode failed: $e');
      return const [];
    }
  }

  Future<Position?> _resolvePosition() async {
    final cachedPosition = await Geolocator.getLastKnownPosition();
    if (_isUsableCachedPosition(cachedPosition)) return cachedPosition;
    final freshPosition = await _getFreshPosition();
    return freshPosition ?? cachedPosition;
  }

  bool _isUsableCachedPosition(Position? position) {
    if (position == null) return false;
    if (position.accuracy > _cachedPositionMaxAccuracyMeters) return false;
    return DateTime.now().difference(position.timestamp) <=
        _cachedPositionMaxAge;
  }

  Future<Position?> _getFreshPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint('[Location] fresh position failed: $e');
      return null;
    }
  }

  Future<Failure?> _ensurePermission() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) return const LocationServiceDisabledFailure();

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return const LocationPermissionFailure();
    }
    return null;
  }
}
