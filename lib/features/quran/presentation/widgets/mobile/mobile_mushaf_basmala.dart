import 'package:flutter/material.dart';

import '../../../domain/entities/reading_theme.dart';

/// Calligraphic «بسم الله الرحمن الرحيم» rendered as the PNG image used by
/// Skoon-Flutter-Islamic-App. Geometry matches their `Basmallah` widget
/// exactly: a screen-width `SizedBox` with 20% horizontal padding on each
/// side, leaving the image at 40% of screen width, tinted to the active
/// reading palette.
///
/// Returns an empty widget for:
///   • surah 1 (basmala is itself ayah 1 of Al-Fatihah)
///   • surah 9 (At-Tawbah has no basmala by tradition)
class MobileMushafBasmala extends StatelessWidget {
  final int surahNumber;
  final double fontSize;
  final ReadingPalette palette;

  const MobileMushafBasmala({
    super.key,
    required this.surahNumber,
    required this.fontSize,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    if (surahNumber == 1 || surahNumber == 9) {
      return const SizedBox.shrink();
    }
    final w = MediaQuery.of(context).size.width;
    return SizedBox(
      width: w,
      child: Padding(
        padding: EdgeInsets.only(
          left: w * 0.2,
          right: w * 0.2,
          top: 8,
          bottom: 2,
        ),
        child: Image.asset(
          'assets/images/basmala.png',
          color: palette.text.withValues(alpha: 0.9),
          width: w * 0.4,
        ),
      ),
    );
  }
}
