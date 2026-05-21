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
/// Each ayah is tappable via its own [TapGestureRecognizer] and gets a
/// strong highlight + underline when it's the currently-playing ayah.
class MobileMushafAyahText extends StatefulWidget {
  final List<Ayah> ayahs;
  final MushafReaderState state;
  final void Function(Ayah ayah) onTap;

  const MobileMushafAyahText({
    super.key,
    required this.ayahs,
    required this.state,
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
    final palette = ReadingPalette.of(widget.state.readingTheme);
    final fontSize = widget.state.fontSize;
    final base = TextStyle(
      fontFamily: 'AmiriQuran',
      fontFamilyFallback: const ['Cairo'],
      fontSize: fontSize,
      height: 2.0,
      color: palette.text,
    );

    final spans = <InlineSpan>[];
    for (final ayah in widget.ayahs) {
      if (ayah.isQuarterStart) {
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
                decoration: TextDecoration.underline,
                decorationColor: palette.marker,
                decorationThickness: 2,
                fontWeight: FontWeight.w600,
              )
            : base,
      ));
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
        text: TextSpan(children: spans),
      ),
    );
  }
}
