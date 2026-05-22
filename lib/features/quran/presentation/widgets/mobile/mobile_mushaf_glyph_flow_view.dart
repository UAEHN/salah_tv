import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/mushaf_glyph_page.dart';
import '../../../domain/entities/reading_theme.dart';

/// Reading-style zoom of a Mushaf glyph page. Renders ALL of the
/// page's word glyphs into a single justified RichText so the text
/// wraps naturally to multiple visual rows within the viewport width.
///
/// Used when the user enlarges the font slider past 26 — the printed
/// 15-line Mushaf structure is intentionally relaxed at zoom so the
/// reader gets bigger, comfortably readable text without:
///   • horizontal scroll (the column never exceeds the viewport)
///   • clipped edges (every word stays visible)
///   • awkward `spaceBetween` gaps that stretch when the line is wider
///     than the words combined.
class MobileMushafGlyphFlowView extends StatefulWidget {
  final MushafGlyphPage page;
  final ReadingPalette palette;
  final double glyphSize;
  final String? playingVerseKey;
  final void Function(String verseKey)? onWordTap;

  const MobileMushafGlyphFlowView({
    super.key,
    required this.page,
    required this.palette,
    required this.glyphSize,
    required this.playingVerseKey,
    required this.onWordTap,
  });

  @override
  State<MobileMushafGlyphFlowView> createState() =>
      _MobileMushafGlyphFlowViewState();
}

class _MobileMushafGlyphFlowViewState extends State<MobileMushafGlyphFlowView> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _registerTap(String verseKey) {
    final r = TapGestureRecognizer()
      ..onTap = () => widget.onWordTap?.call(verseKey);
    _recognizers.add(r);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    // Spans (and their recognizers) are rebuilt every frame because
    // RichText doesn't accept a stable identity for them; dispose the
    // old set first so they don't leak.
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final palette = widget.palette;
    final base = TextStyle(
      fontFamily: widget.page.fontFamily,
      fontSize: widget.glyphSize,
      color: palette.text,
      height: 1.7,
    );
    final markerStyle = base.copyWith(color: palette.marker);

    final spans = <InlineSpan>[];
    for (final line in widget.page.lines) {
      for (final w in line.words) {
        final isPlaying = widget.playingVerseKey == w.verseKey;
        final wordStyle = w.isEndOfAyah ? markerStyle : base;
        final effective = isPlaying
            ? wordStyle.copyWith(
                color: palette.marker,
                background: Paint()..color = palette.highlight,
              )
            : wordStyle;
        spans.add(TextSpan(
          text: w.code,
          style: effective,
          recognizer: _registerTap(w.verseKey),
        ));
        spans.add(const TextSpan(text: ' '));
      }
    }

    return Container(
      color: palette.pageBg,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: RichText(
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            text: TextSpan(children: spans),
          ),
        ),
      ),
    );
  }
}
