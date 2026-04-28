import 'dart:convert';

import '../../../quran/domain/entities/quran_playback_mode.dart';
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

/// Decodes the new 3-mode enum, with migration from the legacy 2-mode model.
/// Old `singleSurah + surahRepeatMode=playlist` becomes [QuranPlaybackMode.playlist].
QuranPlaybackMode decodePlaybackMode(Object? raw, Object? legacyRepeatRaw) {
  if (raw == 'continuous') return QuranPlaybackMode.continuous;
  if (raw == 'playlist') return QuranPlaybackMode.playlist;
  if (raw == 'singleSurah') {
    if (legacyRepeatRaw == 'playlist') return QuranPlaybackMode.playlist;
    return QuranPlaybackMode.singleSurah;
  }
  return QuranPlaybackMode.continuous;
}

/// Migrates legacy `surahRepeatMode` to the new finite-count model.
/// `once` → 1, `repeat` → ∞, `playlist` → 1 (mode is now playlist itself).
int legacyRepeatCountFor(Object? legacyRepeatRaw, int defaultCount) {
  if (legacyRepeatRaw == 'repeat') return -1;
  if (legacyRepeatRaw == 'once') return 1;
  return defaultCount;
}

ContinuousStartMode decodeContinuousStartMode(Object? raw) {
  if (raw == 'random') return ContinuousStartMode.random;
  return ContinuousStartMode.resume;
}

List<String> decodeStringList(Object? raw) {
  if (raw is! String || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  } on Object {
    return const [];
  }
}

List<int> decodeSurahPlaylist(Object? raw) {
  if (raw is! String || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<num>()
        .map((n) => n.toInt())
        .where((n) => n >= 1 && n <= 114)
        .toList(growable: false);
  } on Object {
    return const [];
  }
}
