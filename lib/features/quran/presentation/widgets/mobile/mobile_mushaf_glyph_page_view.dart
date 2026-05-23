import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import '../../../data/qcf_verse_text_repository.dart';
import '../../../domain/entities/reading_theme.dart';
import 'mobile_mushaf_basmala.dart';
import 'mobile_mushaf_surah_header.dart';

/// Mushaf v2 BSML page rendered exactly like Skoon's `QuranPageView`:
/// one justified `RichText` per page driven by the page-specific QCF v2
/// font (`QCF_P{NNN}`). Surah-frame banners and the basmala image are
/// injected as `WidgetSpan`s at every ayah-1 boundary. Per-page font
/// sizes come from the same hardcoded table Skoon uses (28sp on pages
/// 1-2, 22.4-22.5 on the calligrapher's dense pages, 22.9 elsewhere),
/// scaled by `.sp` for responsive calibration on any screen.
///
/// Stateful with a span cache: the `InlineSpan` list is rebuilt only
/// when `pageNumber` / `palette` / `playingVerseKey` actually change.
/// Audio-progress `BlocBuilder` firings that don't move the playing
/// ayah no longer re-layout the `RichText` — that's the difference
/// between swipe-feels-heavy and silky swipes in debug mode. Tap
/// recognizers are kept in a per-State map so they survive rebuilds
/// (no per-frame allocation; clean disposal in `dispose`).
class MobileMushafGlyphPageView extends StatefulWidget {
  final int pageNumber;
  final ReadingPalette palette;
  final void Function(int surah, int ayah)? onAyahTap;
  final String? playingVerseKey;

  /// User font-size multiplier applied on top of the per-page Skoon
  /// base size. 1.0 = printed-Mushaf default; 1.3 = ~30% bigger; etc.
  final double fontScale;

  const MobileMushafGlyphPageView({
    super.key,
    required this.pageNumber,
    required this.palette,
    this.onAyahTap,
    this.playingVerseKey,
    this.fontScale = 1.0,
  });

  @override
  State<MobileMushafGlyphPageView> createState() =>
      _MobileMushafGlyphPageViewState();
}

class _MobileMushafGlyphPageViewState extends State<MobileMushafGlyphPageView> {
  List<InlineSpan>? _cachedSpans;
  int? _cacheKeyPage;
  ReadingPalette? _cacheKeyPalette;
  String? _cacheKeyPvk;
  final Map<String, TapGestureRecognizer> _recognizers = {};

  bool get _isTwoFirstPages =>
      widget.pageNumber == 1 || widget.pageNumber == 2;
  bool get _isTawbahStart => widget.pageNumber == 187;

  double _pageFontSize() {
    if (_isTwoFirstPages) return 28.0;
    if (widget.pageNumber == 532 || widget.pageNumber == 533) return 22.5;
    if (widget.pageNumber == 145 || widget.pageNumber == 201) return 22.4;
    return 22.9;
  }

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  TapGestureRecognizer _recognizerFor(int surah, int ayah) {
    final key = '$surah:$ayah';
    final existing = _recognizers[key];
    if (existing != null) return existing;
    final r = TapGestureRecognizer()
      ..onTap = () => widget.onAyahTap?.call(surah, ayah);
    _recognizers[key] = r;
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sp = size.width / 392.72;
    final family = 'QCF_P${widget.pageNumber.toString().padLeft(3, '0')}';
    final fontSize = _pageFontSize() * sp * widget.fontScale;
    return Container(
      color: widget.palette.pageBg,
      child: SafeArea(
        // Top inset is already absorbed by the per-page header's own
        // SafeArea, so skip it here — otherwise the page glyphs would
        // sit ~30 px below the header on notched devices.
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * sp),
          child: LayoutBuilder(
            builder: (context, c) {
              final topSpacer = _isTwoFirstPages ? size.height * 0.15 : 0.0;
              final fixed = topSpacer + 2;
              // Line-height factor that ALWAYS makes 15 printed-Mushaf
              // lines fit in the current viewport — no scroll bar, no
              // hidden tail when the playing-bar shrinks the available
              // height. Clamped to a sane readability range.
              final needed = (c.maxHeight - fixed) / (15 * fontSize);
              final lineHeight = _isTwoFirstPages
                  ? 2.0
                  : needed.clamp(1.5, 3.0).toDouble();
              final spans = _getCachedSpans(fontSize, family, lineHeight);
              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (_isTwoFirstPages) SizedBox(height: topSpacer),
                    const SizedBox(height: 2),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: SizedBox(
                        width: double.infinity,
                        child: RichText(
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          locale: const Locale('ar'),
                          text: TextSpan(
                            style: TextStyle(
                              color: widget.palette.text,
                              fontSize: fontSize,
                              fontFamily: family,
                              height: lineHeight,
                              letterSpacing: 0,
                              wordSpacing: 0,
                            ),
                            children: spans,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _getCachedSpans(
      double fontSize, String family, double lineHeight) {
    if (_cachedSpans != null &&
        _cacheKeyPage == widget.pageNumber &&
        _cacheKeyPalette == widget.palette &&
        _cacheKeyPvk == widget.playingVerseKey) {
      return _cachedSpans!;
    }
    _cachedSpans = _buildSpans(fontSize, family, lineHeight);
    _cacheKeyPage = widget.pageNumber;
    _cacheKeyPalette = widget.palette;
    _cacheKeyPvk = widget.playingVerseKey;
    return _cachedSpans!;
  }

  List<InlineSpan> _buildSpans(
      double fontSize, String family, double lineHeight) {
    final spans = <InlineSpan>[];
    for (final segment in quran.getPageData(widget.pageNumber)) {
      final surah = segment['surah'] as int;
      final start = segment['start'] as int;
      final end = segment['end'] as int;
      for (var v = start; v <= end; v++) {
        if (v == 1) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MobileMushafSurahHeader(
              surahNumber: surah,
              glyphSize: fontSize,
              palette: widget.palette,
            ),
          ));
          if (!_isTawbahStart && surah != 1) {
            spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: MobileMushafBasmala(
                surahNumber: surah,
                fontSize: fontSize,
                palette: widget.palette,
              ),
            ));
          } else if (_isTawbahStart) {
            spans.add(const WidgetSpan(child: SizedBox(height: 10)));
          }
        }
        final qcf = QcfVerseTextRepository.getVerseQcf(surah, v);
        final isPlaying = widget.playingVerseKey == '$surah:$v';
        final text = v == start && qcf.length > 1
            ? '${qcf.substring(0, 1)} ${qcf.substring(1)}'
            : qcf;
        // Only the per-span fields go here. fontSize / family / height
        // inherit from the parent TextSpan style, so the cached span
        // list survives line-height / font-size changes without rebuild.
        spans.add(TextSpan(
          text: text,
          style: TextStyle(
            backgroundColor:
                isPlaying ? widget.palette.highlight : Colors.transparent,
          ),
          recognizer:
              widget.onAyahTap == null ? null : _recognizerFor(surah, v),
        ));
      }
    }
    return spans;
  }
}
