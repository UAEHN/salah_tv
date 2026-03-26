import '../../../core/city_translations.dart';
import 'location_text_normalizer.dart';

class LocationCountryMatcher {
  static const _isoToCountryKey = <String, String>{
    'AE': 'UAE',
    'OM': 'Oman',
    'SA': 'Saudi',
    'KW': 'Kuwait',
    'QA': 'Qatar',
    'BH': 'Bahrain',
    'EG': 'Egypt',
    'IQ': 'Iraq',
    'JO': 'Jordan',
    'LB': 'Lebanon',
    'MA': 'Morocco',
    'PS': 'Palestine',
    'SY': 'Syria',
    'TN': 'Tunisia',
    'YE': 'Yemen',
  };

  static const _nameToCountryKey = <String, String>{
    'united arab emirates': 'UAE',
    'uae': 'UAE',
    'saudi arabia': 'Saudi',
    'kingdom of saudi arabia': 'Saudi',
    'state of palestine': 'Palestine',
    'palestinian territories': 'Palestine',
    'syrian arab republic': 'Syria',
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
      final isoMatch = _isoToCountryKey[normalizedIsoCode];
      if (isoMatch != null) {
        return (dbKey: isoMatch, displayName: isoMatch);
      }
    }

    for (final name in names) {
      final normalizedName = normalizeLocationText(name);
      final aliasMatch = _nameToCountryKey[normalizedName];
      if (aliasMatch != null) {
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
