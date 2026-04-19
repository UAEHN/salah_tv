/// Result of GPS-based location detection.
///
/// When [isInDb] is true the bundled SQLite data will be used.
/// Otherwise the app falls back to astronomical calculation via adhan_dart.
class DetectedLocation {
  final String countryName;
  final String cityName;
  final double latitude;
  final double longitude;

  /// ISO 3166-1 alpha-2 country code from reverse geocoding (e.g. "TR").
  final String? isoCountryCode;

  /// Non-null when the detected country exists in the bundled prayer DB.
  final String? dbCountryKey;

  /// Non-null when the detected city exists in the bundled prayer DB.
  final String? dbCityKey;

  /// Calculation method resolved for non-DB detected locations.
  final String? calculationMethod;

  /// IANA timezone identifier such as "Europe/Berlin" when available.
  final String? timeZoneId;

  /// UTC offset of the detected/nearest city for non-DB locations.
  final double? utcOffsetHours;

  const DetectedLocation({
    required this.countryName,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    this.isoCountryCode,
    this.dbCountryKey,
    this.dbCityKey,
    this.calculationMethod,
    this.timeZoneId,
    this.utcOffsetHours,
  });

  bool get isInDb => dbCountryKey != null && dbCityKey != null;
}
