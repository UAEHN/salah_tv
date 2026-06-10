import 'package:flutter/material.dart';

/// Three discrete reading themes for the Mushaf reader, independent of
/// the global app theme. Users pick the one easiest on their eyes for
/// the current lighting condition.
enum ReadingTheme { paper, sepia, night }

/// Resolved palette for a [ReadingTheme]. All colours are absolute (not
/// derived from `Theme.of`) so the reading surface looks consistent
/// regardless of the active app palette.
class ReadingPalette {
  final Color screenBg;
  final Color pageBg;
  final Color pageBorder;
  final Color text;
  final Color marker;
  final Color highlight;
  final Color appBarFg;

  /// `true` for the night palette — the reader uses this to invert
  /// the cream-paper page image so it shows white-on-dark instead.
  final bool isDark;

  const ReadingPalette({
    required this.screenBg,
    required this.pageBg,
    required this.pageBorder,
    required this.text,
    required this.marker,
    required this.highlight,
    required this.appBarFg,
    this.isDark = false,
  });

  static const ReadingPalette paper = ReadingPalette(
    screenBg: Color(0xFFF6EFDE),
    pageBg: Color(0xFFFDF8E8),
    pageBorder: Color(0x33B58A3F),
    text: Color(0xFF1C1304),
    marker: Color(0xFFB58A3F),
    highlight: Color(0x44D4A843),
    appBarFg: Color(0xFF2A1F0E),
  );

  static const ReadingPalette sepia = ReadingPalette(
    screenBg: Color(0xFFE6D7B5),
    pageBg: Color(0xFFF1E3C8),
    pageBorder: Color(0x55765322),
    text: Color(0xFF3E2D14),
    marker: Color(0xFF8C5E14),
    highlight: Color(0x55C18A2A),
    appBarFg: Color(0xFF3E2D14),
  );

  static const ReadingPalette night = ReadingPalette(
    screenBg: Color(0xFF0E0F14),
    pageBg: Color(0xFF181A22),
    pageBorder: Color(0x33D4A843),
    text: Color(0xFFE6DAB8),
    marker: Color(0xFFD4A843),
    highlight: Color(0x55D4A843),
    appBarFg: Color(0xFFE6DAB8),
    isDark: true,
  );

  static ReadingPalette of(ReadingTheme t) => switch (t) {
    ReadingTheme.paper => paper,
    ReadingTheme.sepia => sepia,
    ReadingTheme.night => night,
  };
}
