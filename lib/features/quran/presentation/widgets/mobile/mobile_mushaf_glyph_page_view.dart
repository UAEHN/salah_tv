import 'package:flutter/material.dart';

import '../../../domain/entities/mushaf_glyph_page.dart';
import '../../../domain/entities/reading_theme.dart';
import 'mobile_mushaf_glyph_flow_view.dart';
import 'mobile_mushaf_glyph_line.dart';

/// Mushaf v1 page rendered with its dedicated TTF.
///
///   • [fontScale] == 1.0 — printed Madinah layout: 15 lines per body
///     page, exact viewport fit. This is the "natural Mushaf" look
///     the reader expects at the floor font (26).
///   • [fontScale] >  1.0 — hands the page off to
///     [MobileMushafGlyphFlowView] which streams the words into one
///     justified RichText that wraps within the viewport. Vertical
///     scroll only, no clipping, words flow naturally.
class MobileMushafGlyphPageView extends StatelessWidget {
  final MushafGlyphPage page;
  final ReadingPalette palette;
  final void Function(String verseKey)? onWordTap;
  final String? playingVerseKey;
  final double fontScale;
  const MobileMushafGlyphPageView({
    super.key,
    required this.page,
    required this.palette,
    this.onWordTap,
    this.playingVerseKey,
    this.fontScale = 1.0,
  });

  static final Map<int, double> _naturalSizeCache = {};
  bool get _isShortPage => page.lines.length <= 8;
  bool get _isZoomed => fontScale > 1.001;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const pad = 14.0;
        final lineWidth = c.maxWidth - pad * 2;
        final naturalSize = _naturalGlyphSize(lineWidth);
        if (_isZoomed) {
          return MobileMushafGlyphFlowView(
            page: page,
            palette: palette,
            glyphSize: naturalSize * fontScale,
            playingVerseKey: playingVerseKey,
            onWordTap: onWordTap,
          );
        }
        return _mushafBody(naturalSize, pad);
      },
    );
  }

  Widget _mushafBody(double glyphSize, double pad) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: palette.pageBg,
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
        child: Column(
          mainAxisAlignment: _isShortPage
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final line in page.lines)
              MobileMushafGlyphLine(
                line: line,
                fontFamily: page.fontFamily,
                glyphSize: glyphSize,
                palette: palette,
                centered: _isShortPage,
                playingVerseKey: playingVerseKey,
                onWordTap: onWordTap,
              ),
          ],
        ),
      ),
    );
  }

  // Largest glyph size where the widest line still fits the viewport
  // at scale 1. Cached per (page, viewport-width); zoom is applied as
  // a multiplier by the caller so this stays scale-independent.
  double _naturalGlyphSize(double lineWidth) {
    final key = page.pageNumber * 100000 + lineWidth.round();
    final cached = _naturalSizeCache[key];
    if (cached != null) return cached;
    final base = _isShortPage ? lineWidth / 12 : lineWidth / 16;
    var widest = 0.0;
    for (final line in page.lines) {
      final tp = TextPainter(
        text: TextSpan(
          text: line.words.map((w) => w.code).join(''),
          style: TextStyle(fontFamily: page.fontFamily, fontSize: base),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      var w = tp.width;
      tp.dispose();
      if (_isShortPage && line.words.length > 1) {
        w += (line.words.length - 1) * (base * 0.35);
      }
      if (w > widest) widest = w;
    }
    final usable = lineWidth * (_isShortPage ? 0.98 : 0.88);
    final result = widest <= usable ? base : base * (usable / widest);
    _naturalSizeCache[key] = result;
    return result;
  }
}
