import '../../domain/entities/remote_city_result.dart';

/// Parses a single entry from Nominatim's `/search` JSON response.
///
/// Relevant subset of the schema:
///   { place_id, lat, lon, display_name, name,
///     namedetails: { "name:ar": ..., name: ... },
///     address: { country_code, city/town/village/state, ... } }
class NominatimPlaceModel {
  final String placeId;
  final double lat;
  final double lon;
  final String displayName;
  final String name;
  final String? nameAr;
  final String? countryCode;

  const NominatimPlaceModel({
    required this.placeId,
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.name,
    this.nameAr,
    this.countryCode,
  });

  factory NominatimPlaceModel.fromJson(Map<String, dynamic> json) {
    final nameDetails = json['namedetails'];
    String? ar;
    String fallbackName = (json['name'] as String?) ?? '';
    if (nameDetails is Map) {
      ar = nameDetails['name:ar'] as String?;
      if (fallbackName.isEmpty) {
        fallbackName = (nameDetails['name'] as String?) ?? '';
      }
    }
    final address = json['address'];
    String? cc;
    if (address is Map) {
      cc = (address['country_code'] as String?)?.toUpperCase();
    }
    final display = (json['display_name'] as String?) ?? fallbackName;
    final resolvedName = fallbackName.isNotEmpty
        ? fallbackName
        : display.split(',').first.trim();
    return NominatimPlaceModel(
      placeId: '${json['place_id'] ?? ''}',
      lat: double.tryParse('${json['lat']}') ?? 0.0,
      lon: double.tryParse('${json['lon']}') ?? 0.0,
      displayName: display,
      name: resolvedName,
      nameAr: (ar != null && ar.isNotEmpty) ? ar : null,
      countryCode: cc,
    );
  }

  /// Returns null when the row is unusable (no country / no coords / no id).
  /// Such rows are dropped at the repository layer rather than surfaced.
  RemoteCityResult? toEntity() {
    if (countryCode == null || countryCode!.isEmpty) return null;
    if (placeId.isEmpty) return null;
    if (lat == 0.0 && lon == 0.0) return null;
    return RemoteCityResult(
      nameEn: name,
      nameAr: nameAr,
      displayName: displayName,
      countryCode: countryCode!,
      latitude: lat,
      longitude: lon,
      placeId: placeId,
    );
  }
}
