import 'dart:convert';

/// Result returned by [parseCityJson].
typedef CityJsonPayload = ({String hash, List<List<int>> rows});

/// Parses a city JSON response body into a [CityJsonPayload].
///
/// MUST be a top-level function — called via [compute()] in an isolate.
/// No Flutter platform channels are reachable from an isolate.
///
/// Throws [FormatException] when:
///   - Body is not valid JSON (e.g. captive-portal HTML page).
///   - Required fields ("v", "hash", "rows") are missing or wrong type.
///   - Any row has fewer than 7 integer columns.
CityJsonPayload parseCityJson(String body) {
  final Map<String, dynamic> json;
  try {
    json = jsonDecode(body) as Map<String, dynamic>;
  } catch (_) {
    throw const FormatException('Response is not valid JSON');
  }

  if (json['v'] == null || json['hash'] == null || json['rows'] == null) {
    throw const FormatException('Missing required fields: v, hash, or rows');
  }

  final hash    = json['hash'] as String;
  final rawRows = json['rows'] as List<dynamic>;
  final rows    = <List<int>>[];

  for (final raw in rawRows) {
    final row = (raw as List<dynamic>).cast<int>();
    if (row.length < 7) {
      throw const FormatException('Row has fewer than 7 columns');
    }
    rows.add(row);
  }

  return (hash: hash, rows: rows);
}
