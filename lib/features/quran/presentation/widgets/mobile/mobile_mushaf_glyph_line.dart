import 'package:flutter/material.dart';

import '../../../domain/entities/mushaf_glyph_page.dart';
import '../../../domain/entities/reading_theme.dart';

/// One line of a Mushaf glyph page rendered as the printed Madinah
/// layout: a Row with `MainAxisAlignment.spaceBetween` so the words
/// sit justified across the line width. Highlights the currently
/// playing verse by recolouring matching words and painting the
/// palette's highlight as their background.
class MobileMushafGlyphLine extends StatelessWidget {
  final MushafGlyphLine line;
  final String fontFamily;
  final double glyphSize;
  final ReadingPalette palette;
  final bool centered;
  final String? playingVerseKey;
  final void Function(String verseKey)? onWordTap;

  const MobileMushafGlyphLine({
    super.key,
    required this.line,
    required this.fontFamily,
    required this.glyphSize,
    required this.palette,
    required this.centered,
    required this.playingVerseKey,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
        fontFamily: fontFamily,
        fontSize: glyphSize,
        color: palette.text,
        height: 1.0);
    final markerStyle = base.copyWith(color: palette.marker);
    return Row(
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < line.words.length; i++) ...[
          if (centered && i > 0) SizedBox(width: glyphSize * 0.35),
          _wordWidget(line.words[i],
              line.words[i].isEndOfAyah ? markerStyle : base),
        ],
      ],
    );
  }

  Widget _wordWidget(MushafGlyphWord w, TextStyle style) {
    final isPlaying = playingVerseKey != null && w.verseKey == playingVerseKey;
    final effective = isPlaying
        ? style.copyWith(
            color: palette.marker,
            background: Paint()..color = palette.highlight)
        : style;
    final text =
        Text(w.code, style: effective, textDirection: TextDirection.rtl);
    if (onWordTap == null) return text;
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onWordTap!(w.verseKey),
        child: text);
  }
}
