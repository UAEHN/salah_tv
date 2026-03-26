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

  const DetectedLocation({
    required this.countryName,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    this.isoCountryCode,
    this.dbCountryKey,
    this.dbCityKey,
  });

  bool get isInDb => dbCountryKey != null && dbCityKey != null;
}
