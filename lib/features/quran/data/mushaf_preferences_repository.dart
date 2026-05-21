import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/mushaf_preferences.dart';
import '../domain/entities/reading_theme.dart';
import '../domain/i_mushaf_preferences_repository.dart';

/// SharedPreferences-backed store for Mushaf reader preferences.
class MushafPreferencesRepository implements IMushafPreferencesRepository {
  static const _kTheme = 'mushaf_reading_theme';
  static const _kFontSize = 'mushaf_font_size';
  static const _kContinuous = 'mushaf_continuous_playback';
  static const _kReciter = 'mushaf_reciter_id';

  @override
  Future<MushafPreferences> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_kTheme);
      final theme = ReadingTheme.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => ReadingTheme.paper,
      );
      final size = prefs.getDouble(_kFontSize) ?? 26;
      final continuous = prefs.getBool(_kContinuous) ?? false;
      final defaults = const MushafPreferences();
      final reciter = prefs.getString(_kReciter) ?? defaults.reciterId;
      return MushafPreferences(
        readingTheme: theme,
        fontSize: size.clamp(
          MushafPreferences.minFont,
          MushafPreferences.maxFont,
        ),
        continuousPlayback: continuous,
        reciterId: reciter,
      );
    } catch (e) {
      debugPrint('[MushafPrefs] load failed: $e');
      return const MushafPreferences();
    }
  }

  @override
  Future<void> save(MushafPreferences p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTheme, p.readingTheme.name);
      await prefs.setDouble(_kFontSize, p.fontSize);
      await prefs.setBool(_kContinuous, p.continuousPlayback);
      await prefs.setString(_kReciter, p.reciterId);
    } catch (e) {
      debugPrint('[MushafPrefs] save failed: $e');
    }
  }
}
