/// Resolves an IANA timezone id (e.g. "Europe/Berlin") from coordinates.
///
/// Returns null when the lookup fails or the coords don't fall inside
/// any zone — callers should fall back to the device's local zone or
/// UTC-offset mode.
abstract class ITimezoneResolver {
  String? resolve(double latitude, double longitude);
}
