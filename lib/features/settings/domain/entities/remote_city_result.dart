/// City returned by a remote geocoding provider (Nominatim).
///
/// Provenance is implicit in the type — the UI renders rows of this type
/// with a "عالمي" (worldwide) badge to distinguish them from bundled
/// catalog cities.
class RemoteCityResult {
  final String? nameAr;
  final String nameEn;
  final String displayName;

  /// ISO 3166-1 alpha-2, uppercase. Always non-empty — results missing a
  /// country code are filtered out at the repository layer.
  final String countryCode;
  final double latitude;
  final double longitude;

  /// Stable provider id. Used to dedupe identical entries that may appear
  /// twice in a single response (e.g. city + administrative boundary).
  final String placeId;

  const RemoteCityResult({
    required this.nameEn,
    required this.displayName,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    this.nameAr,
  });

  String get preferredLabel => nameAr ?? nameEn;
}
