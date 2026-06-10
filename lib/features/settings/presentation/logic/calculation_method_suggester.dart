import '../../../../core/calculation_method_info.dart';
import '../../../prayer/data/high_latitude_rule_map.dart';

/// What the latitude implies about astronomical-twilight accuracy.
enum HighLatitudeBand {
  /// Below ~48° — standard angles are reliable year-round.
  normal,

  /// 48° – 55° — twilight angles break down on summer nights; pick an
  /// explicit rule (we default to [HighLatitudeRuleKey.twilightAngle]).
  high,

  /// >= 55° — multiple summer days have no astronomical night at all;
  /// the user should be warned that Fajr/Isha will be approximations.
  extreme,
}

/// Pure output of [suggestMethodForLocation]. Holds only string keys so it
/// stays decoupled from any UI/widget code and is trivially testable.
class CalculationSuggestion {
  final String method;
  final String highLatitudeRule;
  final HighLatitudeBand band;

  const CalculationSuggestion({
    required this.method,
    required this.highLatitudeRule,
    required this.band,
  });
}

/// Picks the most sensible calculation method + high-latitude rule for a
/// user who just dropped a pin via worldwide online search.
///
/// Inputs are intentionally narrow:
/// - [isoCountryCode] — 2-letter ISO code from Nominatim's `address.country_code`.
/// - [latitude] — signed decimal degrees; absolute value drives the
///   high-latitude band.
///
/// Reuses [defaultMethodForCountryIso] for the country-to-method mapping
/// so this file does not duplicate the curated list maintained in
/// `calculation_method_info.dart`.
CalculationSuggestion suggestMethodForLocation({
  required String? isoCountryCode,
  required double latitude,
}) {
  final method = defaultMethodForCountryIso(isoCountryCode);
  final absLat = latitude.abs();
  final band = _bandFor(absLat);
  // Below the threshold the calculator's own latitude-based fallback is
  // fine — keep `auto` so we don't override the legacy behavior on the
  // vast majority of locations.
  final rule = band == HighLatitudeBand.normal
      ? HighLatitudeRuleKey.auto
      : HighLatitudeRuleKey.twilightAngle;
  return CalculationSuggestion(
    method: method,
    highLatitudeRule: rule,
    band: band,
  );
}

HighLatitudeBand _bandFor(double absLat) {
  if (absLat >= 55) return HighLatitudeBand.extreme;
  if (absLat >= 48) return HighLatitudeBand.high;
  return HighLatitudeBand.normal;
}
