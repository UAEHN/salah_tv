const Map<String, String> _englishCountryNamesByCode = {
  'AE': 'United Arab Emirates',
  'AF': 'Afghanistan',
  'AL': 'Albania',
  'AR': 'Argentina',
  'AT': 'Austria',
  'AU': 'Australia',
  'AZ': 'Azerbaijan',
  'BA': 'Bosnia and Herzegovina',
  'BD': 'Bangladesh',
  'BE': 'Belgium',
  'BG': 'Bulgaria',
  'BN': 'Brunei',
  'BR': 'Brazil',
  'BY': 'Belarus',
  'CA': 'Canada',
  'CH': 'Switzerland',
  'CL': 'Chile',
  'CN': 'China',
  'CO': 'Colombia',
  'CY': 'Cyprus',
  'CZ': 'Czechia',
  'DE': 'Germany',
  'DJ': 'Djibouti',
  'DK': 'Denmark',
  'DZ': 'Algeria',
  'EG': 'Egypt',
  'EE': 'Estonia',
  'ES': 'Spain',
  'ET': 'Ethiopia',
  'FI': 'Finland',
  'FR': 'France',
  'GE': 'Georgia',
  'GH': 'Ghana',
  'GR': 'Greece',
  'GY': 'Guyana',
  'HR': 'Croatia',
  'HU': 'Hungary',
  'ID': 'Indonesia',
  'IE': 'Ireland',
  'IN': 'India',
  'IQ': 'Iraq',
  'IR': 'Iran',
  'IT': 'Italy',
  'JO': 'Jordan',
  'JP': 'Japan',
  'KE': 'Kenya',
  'KG': 'Kyrgyzstan',
  'KM': 'Comoros',
  'KR': 'South Korea',
  'KW': 'Kuwait',
  'KZ': 'Kazakhstan',
  'LB': 'Lebanon',
  'LT': 'Lithuania',
  'LV': 'Latvia',
  'LY': 'Libya',
  'MA': 'Morocco',
  'MD': 'Moldova',
  'ME': 'Montenegro',
  'MK': 'North Macedonia',
  'ML': 'Mali',
  'MR': 'Mauritania',
  'MV': 'Maldives',
  'MX': 'Mexico',
  'MY': 'Malaysia',
  'NE': 'Niger',
  'NG': 'Nigeria',
  'NL': 'Netherlands',
  'NO': 'Norway',
  'NZ': 'New Zealand',
  'OM': 'Oman',
  'PE': 'Peru',
  'PH': 'Philippines',
  'PK': 'Pakistan',
  'PL': 'Poland',
  'PS': 'Palestine',
  'PT': 'Portugal',
  'QA': 'Qatar',
  'RO': 'Romania',
  'RS': 'Serbia',
  'RU': 'Russia',
  'SA': 'Saudi Arabia',
  'SD': 'Sudan',
  'SE': 'Sweden',
  'SG': 'Singapore',
  'SI': 'Slovenia',
  'SK': 'Slovakia',
  'SN': 'Senegal',
  'SO': 'Somalia',
  'SR': 'Suriname',
  'SY': 'Syria',
  'TD': 'Chad',
  'TH': 'Thailand',
  'TJ': 'Tajikistan',
  'TM': 'Turkmenistan',
  'TN': 'Tunisia',
  'TR': 'Turkey',
  'TT': 'Trinidad and Tobago',
  'TZ': 'Tanzania',
  'UA': 'Ukraine',
  'UK': 'United Kingdom',
  'US': 'United States',
  'UZ': 'Uzbekistan',
  'XK': 'Kosovo',
  'YE': 'Yemen',
  'ZA': 'South Africa',
};

/// ISO-2 country code → DB country key (lowercase, as stored in prayer_times.db).
/// Used to de-duplicate the country picker: if an ISO code maps to a key that's
/// currently in the DB, the world-list entry is hidden so DB-backed times win
/// (they're more accurate than calculated-from-lat/lng).
const Map<String, String> _dbCountryKeyByIsoCode = {
  'AE': 'uae',
  'BH': 'bahrain',
  'DZ': 'algeria',
  'EG': 'egypt',
  'IQ': 'iraq',
  'JO': 'jordan',
  'KW': 'kuwait',
  'LB': 'lebanon',
  'LY': 'libya',
  'MA': 'morocco',
  'MY': 'malaysia',
  'OM': 'oman',
  'PS': 'palestine',
  'QA': 'qatar',
  'SA': 'saudi',
  'SG': 'singapore',
  'SY': 'syria',
  'TN': 'tunisia',
  'YE': 'yemen',
};

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
