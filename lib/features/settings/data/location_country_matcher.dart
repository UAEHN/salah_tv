import '../../../core/city_translations.dart';
import '../../../core/country_name_resolver.dart';
import 'location_text_normalizer.dart';

class LocationCountryMatcher {
  // ISO code → DB key mapping lives in country_name_resolver.dart so there's
  // a single source of truth for "which ISO codes are DB-backed".

  static const _nameToCountryKey = <String, String>{
    'united arab emirates': 'uae',
    'uae': 'uae',
    'saudi arabia': 'saudi',
    'kingdom of saudi arabia': 'saudi',
    'state of palestine': 'palestine',
    'palestinian territories': 'palestine',
    'syrian arab republic': 'syria',
  };

  /// Returns the DB key (if the country is in the bundled DB) and a
  /// human-readable display name. Returns `null` only when no country
  /// name can be resolved at all.
  ({String? dbKey, String displayName})? match({
    required String? isoCode,
    required Iterable<String> names,
  }) {
    final normalizedIsoCode = isoCode?.trim().toUpperCase();
    if (normalizedIsoCode != null) {
      final isoMatch = dbCountryKeyForIso(normalizedIsoCode);
      if (isoMatch != null && kDbCountryKeys.contains(isoMatch)) {
        return (dbKey: isoMatch, displayName: isoMatch);
      }
    }

    for (final name in names) {
      final normalizedName = normalizeLocationText(name);
      final aliasMatch = _nameToCountryKey[normalizedName];
      if (aliasMatch != null && kDbCountryKeys.contains(aliasMatch)) {
        return (dbKey: aliasMatch, displayName: aliasMatch);
      }
      for (final country in kCountries) {
        if (normalizeLocationText(country.key) == normalizedName) {
          return (dbKey: country.key, displayName: country.key);
        }
      }
    }

    // Country not in DB — return display name from geocoding.
    for (final name in names) {
      if (name.trim().isNotEmpty) {
        return (dbKey: null, displayName: name.trim());
      }
    }
    return null;
  }
}
