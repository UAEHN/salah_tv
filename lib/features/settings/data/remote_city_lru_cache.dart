import 'dart:collection';

import '../domain/entities/remote_city_result.dart';

/// Small per-query LRU cache for Nominatim results.
///
/// Sized to absorb the common type-then-backspace-then-retype pattern.
/// A cache miss is harmless — Nominatim handles dedupe on its end —
/// so the normalization is intentionally minimal (trim + lowercase),
/// not the full Arabic-aware normalizer used for in-list matching.
class RemoteCityLruCache {
  static const int _capacity = 16;
  final LinkedHashMap<String, List<RemoteCityResult>> _entries =
      LinkedHashMap();

  List<RemoteCityResult>? get(String query) {
    final key = _key(query);
    final value = _entries.remove(key);
    if (value != null) _entries[key] = value;
    return value;
  }

  void put(String query, List<RemoteCityResult> results) {
    final key = _key(query);
    _entries.remove(key);
    _entries[key] = results;
    if (_entries.length > _capacity) {
      _entries.remove(_entries.keys.first);
    }
  }

  String _key(String q) => q.trim().toLowerCase();
}
