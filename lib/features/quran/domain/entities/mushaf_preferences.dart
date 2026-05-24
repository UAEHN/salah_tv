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
    // 30 (zoom 1.083) eats the phone-aspect letterbox so the page
    // fills the screen — a noticeable improvement over 26 (zoom
    // 1.0) which leaves ~17% empty space top + bottom.
    this.fontSize = 30,
    this.continuousPlayback = false,
    this.reciterId = 'husary_muallim',
  });

  /// Allowed slider steps shown in the settings sheet. The reader
  /// renders page images now (not flowing text), so [fontSize] is
  /// repurposed as the zoom-factor driver — see [zoomFactor]. The
  /// field name is kept for backwards-compatible SharedPreferences
  /// storage (existing installs already have `fontSize` saved).
  static const double minFont = 26;
  static const double maxFont = 50;

  /// Visual zoom applied to the Madinah page PNG on top of
  /// `BoxFit.contain`. Linear mapping: slider at min → 1.0× (raw
  /// printed-Mushaf fit), slider at max → 1.5× (significant zoom,
  /// edges clipped to viewport). At ~30 the page eats most of the
  /// phone-aspect letterbox without cropping calligraphy.
  double get zoomFactor {
    final clamped = fontSize.clamp(minFont, maxFont);
    return 1.0 + (clamped - minFont) / (maxFont - minFont) * 0.5;
  }

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
