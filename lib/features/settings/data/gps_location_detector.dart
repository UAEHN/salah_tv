import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/detected_location.dart';
import '../domain/i_location_detector.dart';
import 'location_city_matcher.dart';
import 'location_country_matcher.dart';

/// GPS-based location detector that works worldwide.
///
/// 1. Tries to match to a bundled DB country/city (most accurate times).
/// 2. Falls back to raw coordinates + reverse-geocoded names for
///    astronomical calculation via adhan_dart.
class GpsLocationDetector implements ILocationDetector {
  static const _cachedPositionMaxAge = Duration(minutes: 30);
  static const _cachedPositionMaxAccuracyMeters = 15000.0;

  GpsLocationDetector({
    LocationCountryMatcher? countryMatcher,
    LocationCityMatcher? cityMatcher,
  })  : _countryMatcher = countryMatcher ?? LocationCountryMatcher(),
        _cityMatcher = cityMatcher ?? LocationCityMatcher();

  final LocationCountryMatcher _countryMatcher;
  final LocationCityMatcher _cityMatcher;

  Future<Either<Failure, DetectedLocation>>? _activeDetection;

  @override
  Future<Either<Failure, DetectedLocation>> detectLocation() {
    final activeDetection = _activeDetection;
    if (activeDetection != null) return activeDetection;

    final detection = _detectLocation();
    _activeDetection = detection;
    detection.whenComplete(() {
      if (identical(_activeDetection, detection)) {
        _activeDetection = null;
      }
    });
    return detection;
  }

  Future<Either<Failure, DetectedLocation>> _detectLocation() async {
    final failure = await _ensurePermission();
    if (failure != null) return Left(failure);

    final position = await _resolvePosition();
    if (position == null) {
      return const Left(LocationFailure('Unable to determine location'));
    }

    final placemarks = await _reverseGeocode(position);
    if (placemarks.isEmpty) {
      return const Left(LocationFailure('Unable to read location details'));
    }

    final countryResult = _countryMatcher.match(
      isoCode: placemarks.first.isoCountryCode,
      names: placemarks.map((p) => p.country ?? ''),
    );

    String? dbCountryKey = countryResult?.dbKey;
    String? dbCityKey;
    if (dbCountryKey != null) {
      dbCityKey = _cityMatcher.match(dbCountryKey, placemarks);
    }

    final countryDisplay =
        countryResult?.displayName ?? placemarks.first.country ?? 'Unknown';
    final cityDisplay = _bestCityName(placemarks) ?? 'Unknown';

    return Right(
      DetectedLocation(
        countryName: countryDisplay,
        cityName: dbCityKey ?? cityDisplay,
        latitude: position.latitude,
        longitude: position.longitude,
        isoCountryCode: placemarks.first.isoCountryCode,
        dbCountryKey: dbCityKey != null ? dbCountryKey : null,
        dbCityKey: dbCityKey,
      ),
    );
  }

  String? _bestCityName(List<Placemark> placemarks) {
    for (final p in placemarks.take(3)) {
      final candidate = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea;
      if (candidate != null && candidate.trim().isNotEmpty) return candidate;
    }
    return null;
  }

  Future<List<Placemark>> _reverseGeocode(Position position) async {
    try {
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
    return DateTime.now().difference(position.timestamp) <= _cachedPositionMaxAge;
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
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return const LocationPermissionFailure();
    }
    return null;
  }
}
