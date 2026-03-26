/// A city from the bundled worldwide city catalogue.
///
/// Used for manual location selection when the city is not in the
/// pre-computed SQLite prayer-time database.
class WorldCity {
  final String name;
  final String arabicName;
  final String countryKey;
  final String countryArabic;
  final double latitude;
  final double longitude;
  final String calculationMethod;

  /// UTC offset in hours (e.g. 2.0 for GMT+2, -5.0 for GMT-5).
  final double utcOffset;

  const WorldCity({
    required this.name,
    required this.arabicName,
    required this.countryKey,
    required this.countryArabic,
    required this.latitude,
    required this.longitude,
    required this.calculationMethod,
    required this.utcOffset,
  });
}

/// A country grouping in the worldwide city catalogue.
class WorldCountry {
  final String key;
  final String arabicName;

  const WorldCountry({required this.key, required this.arabicName});
}
