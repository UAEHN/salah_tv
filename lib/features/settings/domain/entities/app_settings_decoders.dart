import 'dart:convert';

import 'custom_adhan.dart';

/// Decoder helpers for [AppSettings] serialized state. Extracted from
/// [app_settings_mapper.dart] to keep each file under the 150-line limit
/// set by CLAUDE.md §4.
String validatedQuranUrl(String url) {
  if (url.isEmpty) return '';
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      !uri.host.endsWith('mp3quran.net')) {
    return '';
  }
  return url;
}

Map<String, bool> decodeBoolMap(dynamic raw, Map<String, bool> fallback) {
  if (raw == null) return fallback;
  try {
    final decoded = jsonDecode(raw as String) as Map;
    return decoded.map((k, v) => MapEntry(k.toString(), v as bool));
  } on Object {
    return fallback;
  }
}

Map<String, int> decodeIntMap(dynamic raw, Map<String, int> fallback) {
  if (raw == null) return fallback;
  try {
    final decoded = jsonDecode(raw as String) as Map;
    return decoded.map((k, v) => MapEntry(k.toString(), v as int));
  } on Object {
    return fallback;
  }
}

List<CustomAdhan> decodeCustomAdhans(dynamic raw) {
  if (raw == null) return const [];
  try {
    final decoded = jsonDecode(raw as String) as List;
    return decoded
        .map((e) => CustomAdhan.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  } on Object {
    return const [];
  }
}

/// Returns [key] if it matches an allowed built-in key or a `custom:<id>`
/// referring to an existing [customs] entry; otherwise `'default'`.
String validatedAdhanSound(String? key, List<CustomAdhan> customs) {
  if (key == null) return 'default';
  if (const ['default', 'adhan2'].contains(key)) return key;
  final fileName = CustomAdhan.extractFileName(key);
  if (fileName != null && customs.any((c) => c.fileName == fileName)) {
    return key;
  }
  return 'default';
}

const defaultBoolMapTrue = {
  'fajr': true,
  'dhuhr': true,
  'asr': true,
  'maghrib': true,
  'isha': true,
};
const defaultBoolMapFalse = {
  'fajr': false,
  'dhuhr': false,
  'asr': false,
  'maghrib': false,
  'isha': false,
};
