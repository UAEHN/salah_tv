/// A geocoded place returned from an online search provider (Nominatim).
///
/// Distinct from bundled cities — these come from the open internet, may
/// include any town/village worldwide, and carry no calculation method
/// (one must be picked downstream by the user / suggester).
///
/// The structured address fields ([subLocality], [administrativeArea],
/// [subAdministrativeArea]) mirror the native `geocoding` package's
/// `Placemark` shape so the same matching pipeline used by GPS auto-detect
/// (LocationCityMatcher: locality → subLocality → admin areas) can be
/// reused without a parallel implementation.
class OnlineGeocodingResult {
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;
  final String countryCode;
  final String? countryName;

  /// Suburb / neighbourhood / quarter — finer-grained than the city.
  final String? subLocality;

  /// State / region — coarser than the city (e.g. "Sharjah Emirate").
  final String? administrativeArea;

  /// State district / county — between the city and the state.
  final String? subAdministrativeArea;

  const OnlineGeocodingResult({
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
    this.countryName,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
  });

  /// Stable identity used by list builders / equality.
  String get id =>
      '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';
}
