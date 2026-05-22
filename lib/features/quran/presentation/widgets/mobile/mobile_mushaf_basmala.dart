import 'package:flutter/material.dart';

import '../../../domain/entities/reading_theme.dart';

/// Plain «بسم الله الرحمن الرحيم» line shown at the top of a surah, just
/// above its first ayah. Matches the ayah text font exactly (same family,
/// same size, same weight) so it reads as a natural part of the page.
///
/// Returns an empty widget for:
///   • surah 1 (the Basmala is itself the first ayah of Al-Fatihah)
///   • surah 9 (At-Tawbah has no Basmala by tradition)
///
/// Takes [fontSize] and [palette] as explicit params so the page
/// container can pass an auto-fit-adjusted size without us reading the
/// cubit directly — keeps the basmala stable when the container shrinks
/// the page font to fit.
class MobileMushafBasmala extends StatelessWidget {
  final int surahNumber;
  final double fontSize;
  final ReadingPalette palette;
  static const String _text = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ';

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
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        _text,
        textAlign: TextAlign.center,
        style: TextStyle(
          // Same primary/fallback chain as the ayah-text renderer so
          // the Basmala and the verses share identical glyph shaping
          // and inline-mark positioning.
          fontFamily: 'AmiriQuran',
          fontFamilyFallback: const ['UthmanicHafs', 'Cairo'],
          fontSize: fontSize,
          color: palette.text,
          height: 1.4,
        ),
      ),
    );
  }
}
