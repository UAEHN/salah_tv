import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;

import '../domain/i_timezone_resolver.dart';

/// Offline lat/lng → IANA timezone lookup via the bundled
/// `lat_lng_to_timezone` polygon table. Avoids an extra network
/// round-trip after the user picks a city from the worldwide search.
class LatLongTimezoneResolver implements ITimezoneResolver {
  const LatLongTimezoneResolver();

  @override
  String? resolve(double latitude, double longitude) {
    try {
      final zone = tzmap.latLngToTimezoneString(latitude, longitude);
      if (zone.isEmpty) return null;
      return zone;
    } catch (_) {
      return null;
    }
  }
}
