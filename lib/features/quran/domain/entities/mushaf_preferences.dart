import 'available_ayah_reciters.dart';
import 'reading_theme.dart';

/// User-tunable reading preferences for the Mushaf reader. Persisted in
/// SharedPreferences via [IMushafPreferencesRepository] — kept separate
/// from the app-wide `AppSettings` because it's a feature-local concern.
class MushafPreferences {
  final ReadingTheme readingTheme;

  /// Base font size for the Uthmani body text. Clamped to a sane range by
  /// the cubit before applying.
  final double fontSize;

  /// When true, the reader auto-plays the next ayah after the current
  /// one finishes (flipping pages as needed).
  final bool continuousPlayback;

  /// Id of the chosen ayah reciter — must match an entry in
  /// [kAvailableAyahReciters], otherwise `resolveReciter` falls back to
  /// the default.
  final String reciterId;

  const MushafPreferences({
    this.readingTheme = ReadingTheme.paper,
    this.fontSize = 26,
    this.continuousPlayback = false,
    this.reciterId = 'husary_muallim',
  });

  /// Allowed font-size steps shown in the settings sheet slider.
  /// 26 is the floor — at that size the printed Mushaf layout fits
  /// the viewport exactly. Any value above switches the reader into
  /// the flowing-text zoom mode.
  static const double minFont = 26;
  static const double maxFont = 50;

  MushafPreferences copyWith({
    ReadingTheme? readingTheme,
    double? fontSize,
    bool? continuousPlayback,
    String? reciterId,
  }) {
    return MushafPreferences(
      readingTheme: readingTheme ?? this.readingTheme,
      fontSize: fontSize ?? this.fontSize,
      continuousPlayback: continuousPlayback ?? this.continuousPlayback,
      reciterId: reciterId ?? this.reciterId,
    );
  }
}
