import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/ayah.dart';
import '../../../domain/entities/reading_theme.dart';
import '../../bloc/mushaf_reader_state.dart';
import 'mushaf_arabic_digits.dart';

/// Renders a contiguous run of ayahs from the same surah as a single
/// justified RichText. Markers added inline:
///   ۞  before any ayah that starts a rub-el-hizb quarter.
///   ۩  after the ayah number for any sajdah-bearing ayah.
/// Each ayah is tappable via its own [TapGestureRecognizer] and is
/// highlighted with a background colour when it's the currently-playing
/// ayah (no underline — the highlight alone is enough).
///
/// [fontSize] and [palette] are passed in by the page container so the
/// auto-fit logic can shrink a long page to fit the viewport without
/// the user having to scroll. [ayahLineHeight] / [fontFamily] are
/// exposed so the container can build a [TextPainter] with the exact
/// same metrics for its measurement pass.
class MobileMushafAyahText extends StatefulWidget {
  static const String fontFamily = 'AmiriQuran';
  static const List<String> fontFamilyFallback = ['UthmanicHafs', 'Cairo'];
  static const double ayahLineHeight = 1.95;

  final List<Ayah> ayahs;
  final MushafReaderState state;
  final double fontSize;
  final ReadingPalette palette;
  final void Function(Ayah ayah) onTap;

  const MobileMushafAyahText({
    super.key,
    required this.ayahs,
    required this.state,
    required this.fontSize,
    required this.palette,
    required this.onTap,
  });

  @override
  State<MobileMushafAyahText> createState() => _MobileMushafAyahTextState();
}

class _MobileMushafAyahTextState extends State<MobileMushafAyahText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _recognizerFor(Ayah a) {
    final r = TapGestureRecognizer()..onTap = () => widget.onTap(a);
    _recognizers.add(r);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    final palette = widget.palette;
    final fontSize = widget.fontSize;
    final base = TextStyle(
      // AmiriQuran (Dr. Khaled Hosny, SIL OFL) is the most reliable
      // Flutter renderer for the Tanzil Uthmani dataset: it positions
      // the inline small-high marks (waqf signs ۖۗۚۛ + alef-wasl ۟ +
      // hamzat al-wasl) as tiny above-line glyphs, not full-size
      // ornaments. UthmanicHafs (KFGQPC) is kept as a fallback for
      // any codepoint Amiri doesn't ship.
      fontFamily: MobileMushafAyahText.fontFamily,
      fontFamilyFallback: MobileMushafAyahText.fontFamilyFallback,
      fontSize: fontSize,
      // 1.95 leaves enough vertical room for Arabic's tall combining
      // marks (shadda + fatha + small-alef stacks) without the airy
      // 2.6 spacing that pushed even short pages off-screen. Auto-fit
      // in the page container shrinks this further when a page still
      // doesn't fit, so the reader never has to scroll at default.
      height: MobileMushafAyahText.ayahLineHeight,
      color: palette.text,
    );

    final spans = <InlineSpan>[];
    for (final ayah in widget.ayahs) {
      // Modern Mushaf convention: suppress the rub-el-hizb marker on
      // Al-Fatihah verse 1. It's technically the start of hizb 1 but no
      // printed Mushaf shows the marker there.
      final showQuarter = ayah.isQuarterStart &&
          !(ayah.surahNumber == 1 && ayah.numberInSurah == 1);
      if (showQuarter) {
        spans.add(TextSpan(
          text: '۞ ',
          style: base.copyWith(
            color: palette.marker,
            fontSize: fontSize * 1.05,
          ),
        ));
      }
      final isPlaying = widget.state.isAyahPlaying(
        ayah.surahNumber,
        ayah.numberInSurah,
      );
      spans.add(TextSpan(
        text: '${ayah.textUthmani} ',
        recognizer: _recognizerFor(ayah),
        style: isPlaying
            ? base.copyWith(
                background: Paint()..color = palette.highlight,
                fontWeight: FontWeight.w600,
              )
            : base,
      ));
      // U+06DD ۝ (end-of-ayah) combines with the trailing Arabic-Indic
      // digit to draw the rosette with the number inside.
      spans.add(TextSpan(
        text: '۝${toArabicIndic(ayah.numberInSurah)} ',
        recognizer: _recognizerFor(ayah),
        style: base.copyWith(
          color: palette.marker,
          fontSize: fontSize * 0.85,
        ),
      ));
      if (ayah.isSajdah) {
        spans.add(TextSpan(
          text: '۩ ',
          style: base.copyWith(
            color: palette.marker,
            fontSize: fontSize * 1.05,
          ),
        ));
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        // StrutStyle locks the baseline-to-baseline distance so spans of
        // mixed sizes (digits at 0.85x, markers at 1.05x) don't squeeze
        // the line and orphan Quranic diacritics onto the previous row.
        strutStyle: StrutStyle(
          fontFamily: MobileMushafAyahText.fontFamily,
          fontSize: fontSize,
          height: MobileMushafAyahText.ayahLineHeight,
          forceStrutHeight: true,
        ),
        text: TextSpan(children: spans),
      ),
    );
  }
}
