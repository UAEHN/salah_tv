import '../../domain/entities/world_city.dart';
import 'location_picker_source.dart';

class LocationChoice {
  final LocationPickerSource source;
  final String countryKey;
  final String cityName;
  final double? latitude;
  final double? longitude;
  final String? calculationMethod;
  final String? timeZoneId;
  final double? utcOffsetHours;

  const LocationChoice._({
    required this.source,
    required this.countryKey,
    required this.cityName,
    this.latitude,
    this.longitude,
    this.calculationMethod,
    this.timeZoneId,
    this.utcOffsetHours,
  });

  factory LocationChoice.database({
    required String countryKey,
    required String cityName,
  }) {
    return LocationChoice._(
      source: LocationPickerSource.db,
      countryKey: countryKey,
      cityName: cityName,
    );
  }

  factory LocationChoice.world(WorldCity city) {
    return LocationChoice._(
      source: LocationPickerSource.world,
      countryKey: city.countryKey,
      cityName: city.name,
      latitude: city.latitude,
      longitude: city.longitude,
      calculationMethod: city.calculationMethod,
      timeZoneId: city.timeZoneId,
      utcOffsetHours: city.utcOffset,
    );
  }

  factory LocationChoice.worldFromValues({
    required String countryKey,
    required String cityName,
    required double latitude,
    required double longitude,
    required String calculationMethod,
    String? timeZoneId,
    double? utcOffsetHours,
  }) {
    return LocationChoice._(
      source: LocationPickerSource.world,
      countryKey: countryKey,
      cityName: cityName,
      latitude: latitude,
      longitude: longitude,
      calculationMethod: calculationMethod,
      timeZoneId: timeZoneId,
      utcOffsetHours: utcOffsetHours,
    );
  }

  bool get isDb => source == LocationPickerSource.db;
}
