// Country name/key resolution.
//
// The translation data (ISO-2 → English name, ISO-2 → DB key) is NOT hardcoded
// here — it lives in the single source of truth `assets/countries.json` and is
// injected at startup by [loadCityTranslations] via [registerCountryTranslations].
// These maps stay empty until that call runs (early in app startup, before any
// picker/geocoding UI), mirroring the mutable-state pattern of `registerDbCountries`.

Map<String, String> _englishCountryNamesByCode = {};

/// ISO-2 country code → DB country key (lowercase, as stored in prayer data).
/// Used to de-duplicate the country picker: if an ISO code maps to a key that's
/// currently in the DB, the world-list entry is hidden so DB-backed times win
/// (they're more accurate than calculated-from-lat/lng).
Map<String, String> _dbCountryKeyByIsoCode = {};

/// Populates the ISO-2 lookup tables from the unified country catalogue.
/// Called once from [loadCityTranslations] after `assets/countries.json` loads.
void registerCountryTranslations({
  required Map<String, String> englishByIso,
  required Map<String, String> dbKeyByIso,
}) {
  _englishCountryNamesByCode = Map.unmodifiable(englishByIso);
  _dbCountryKeyByIsoCode = Map.unmodifiable(dbKeyByIso);
}

String resolveEnglishCountryName(String key) {
  final normalizedKey = key.trim().toUpperCase();
  return _englishCountryNamesByCode[normalizedKey] ?? key;
}

/// Returns the DB country key that corresponds to an ISO-2 code, or null if
/// there is no matching DB-backed country.
String? dbCountryKeyForIso(String isoCode) {
  return _dbCountryKeyByIsoCode[isoCode.trim().toUpperCase()];
}

/// Returns the ISO-2 code for a DB country key (the reverse of
/// [dbCountryKeyForIso]). Used by the settings UI to display each
/// bundled-DB country's natural calculation method.
String? isoForDbCountryKey(String dbKey) {
  final normalized = dbKey.trim().toLowerCase();
  for (final entry in _dbCountryKeyByIsoCode.entries) {
    if (entry.value == normalized) return entry.key;
  }
  return null;
}
