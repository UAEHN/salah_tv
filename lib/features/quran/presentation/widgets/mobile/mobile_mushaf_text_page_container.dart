import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../injection.dart';
import '../../../domain/entities/ayah.dart';
import '../../../domain/entities/mushaf_page.dart';
import '../../../domain/entities/reading_theme.dart';
import '../../../domain/i_quran_text_repository.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import 'mobile_mushaf_ayah_text.dart';
import 'mobile_mushaf_basmala.dart';
import 'mushaf_arabic_digits.dart';
import 'surah_name_glyph.dart';

/// Self-loading wrapper for one Mushaf page rendered as flowing Uthmani
/// text. Honors the user's font-size preference — text grows and reflows
/// naturally, matching how Quran.com / Tarteel / iQuran / Madinah Mushaf
/// behave when the reader slides the font slider.
///
/// Adds **per-page auto-fit**: every page is measured before paint and
/// the font is scaled down (never up) so the page lands inside the
/// viewport without scrolling at the user's preferred size. Long pages
/// like ٱلْبَقَرَة page 3 still show the full content in one screen.
class MobileMushafTextPageContainer extends StatefulWidget {
  final int pageNumber;
  final ReadingPalette palette;
  final void Function(Ayah ayah) onAyahTap;

  const MobileMushafTextPageContainer({
    super.key,
    required this.pageNumber,
    required this.palette,
    required this.onAyahTap,
  });

  @override
  State<MobileMushafTextPageContainer> createState() =>
      _MobileMushafTextPageContainerState();
}

class _MobileMushafTextPageContainerState
    extends State<MobileMushafTextPageContainer> {
  // Layout constants used both at paint time and at measurement time —
  // any divergence between the two would invalidate the auto-fit.
  static const double _hPad = 18;
  static const double _topPad = 14;
  static const double _bottomPad = 28;
  static const double _bannerSizeFactor = 2.2; // banner is fontSize × 2.2
  static const double _bannerTopPad = 14;
  static const double _bannerBottomPad = 4;
  static const double _basmalaHeightFactor = 1.4;
  static const double _basmalaTopPad = 8;
  static const double _basmalaBottomPad = 6;

  /// Memoises the fit result per (page, viewport-width, preferred-size).
  /// PageView rebuilds visible containers as the user swipes, so caching
  /// keeps the auto-fit cost paid once per page and reused thereafter.
  static final Map<int, double> _fitCache = {};

  MushafPage? _page;

  @override
  void initState() {
    super.initState();
    _resolve(widget.pageNumber);
  }

  @override
  void didUpdateWidget(covariant MobileMushafTextPageContainer old) {
    super.didUpdateWidget(old);
    if (old.pageNumber != widget.pageNumber) {
      _resolve(widget.pageNumber);
    }
  }

  void _resolve(int pageNumber) {
    final repo = getIt<IQuranTextRepository>();
    final hit = repo.cachedPage(pageNumber);
    if (hit != null) {
      _page = hit;
      return;
    }
    _page = null;
    _loadAsync(repo, pageNumber);
  }

  Future<void> _loadAsync(IQuranTextRepository repo, int pageNumber) async {
    final res = await repo.getPage(pageNumber);
    if (!mounted || widget.pageNumber != pageNumber) return;
    res.fold((_) {}, (p) => setState(() => _page = p));
  }

  @override
  Widget build(BuildContext context) {
    final p = _page;
    if (p == null) {
      return Container(
        color: widget.palette.pageBg,
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: widget.palette.marker),
      );
    }
    return BlocBuilder<MushafReaderCubit, MushafReaderState>(
      buildWhen: (a, b) =>
          a.fontSize != b.fontSize ||
          a.readingTheme != b.readingTheme ||
          a.audioStatus != b.audioStatus ||
          a.playingSurah != b.playingSurah ||
          a.playingAyah != b.playingAyah,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, c) {
            final innerWidth = c.maxWidth - _hPad * 2;
            final fitFontSize = _fitFontSize(
              page: p,
              preferred: state.fontSize,
              innerWidth: innerWidth,
              viewportHeight: c.maxHeight,
            );
            return Container(
              color: widget.palette.pageBg,
              padding: const EdgeInsets.fromLTRB(
                  _hPad, _topPad, _hPad, _bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildSections(state, p, fitFontSize),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildSections(
      MushafReaderState state, MushafPage page, double fontSize) {
    final sections = <Widget>[];
    for (final group in _groupBySurah(page.ayahs)) {
      if (group.first.isFirstAyahOfSurah) {
        sections.add(_SurahBanner(
          surahNumber: group.first.surahNumber,
          palette: widget.palette,
          fontSize: fontSize,
        ));
        sections.add(MobileMushafBasmala(
          surahNumber: group.first.surahNumber,
          fontSize: fontSize,
          palette: widget.palette,
        ));
      }
      sections.add(MobileMushafAyahText(
        ayahs: group,
        state: state,
        fontSize: fontSize,
        palette: widget.palette,
        onTap: widget.onAyahTap,
      ));
    }
    return sections;
  }

  List<List<Ayah>> _groupBySurah(List<Ayah> ayahs) {
    final groups = <List<Ayah>>[];
    for (final a in ayahs) {
      if (groups.isEmpty || groups.last.first.surahNumber != a.surahNumber) {
        groups.add([a]);
      } else {
        groups.last.add(a);
      }
    }
    return groups;
  }

  // Returns the largest font-size ≤ [preferred] that lays out the whole
  // page within the viewport's vertical space. Result memoised.
  double _fitFontSize({
    required MushafPage page,
    required double preferred,
    required double innerWidth,
    required double viewportHeight,
  }) {
    final cacheKey = page.pageNumber * 1000000 +
        innerWidth.round() * 1000 +
        preferred.round();
    final cached = _fitCache[cacheKey];
    if (cached != null) return cached;
    final required = _measureContentHeight(
        page: page, width: innerWidth, fontSize: preferred);
    final fit = required <= viewportHeight
        ? preferred
        : preferred * (viewportHeight / required);
    // Clamp to a sane minimum so very dense pages never collapse into
    // an unreadable smudge of glyphs.
    final result = fit.clamp(12.0, preferred);
    _fitCache[cacheKey] = result;
    return result;
  }

  double _measureContentHeight({
    required MushafPage page,
    required double width,
    required double fontSize,
  }) {
    var total = _topPad + _bottomPad;
    for (final group in _groupBySurah(page.ayahs)) {
      if (group.first.isFirstAyahOfSurah) {
        total += fontSize * _bannerSizeFactor + _bannerTopPad + _bannerBottomPad;
        final s = group.first.surahNumber;
        if (s != 1 && s != 9) {
          total += fontSize * _basmalaHeightFactor +
              _basmalaTopPad +
              _basmalaBottomPad;
        }
      }
      total += _measureAyahRunHeight(group, width, fontSize);
    }
    return total;
  }

  double _measureAyahRunHeight(
      List<Ayah> ayahs, double width, double fontSize) {
    final buf = StringBuffer();
    for (final a in ayahs) {
      if (a.isQuarterStart && !(a.surahNumber == 1 && a.numberInSurah == 1)) {
        buf.write('۞ ');
      }
      buf.write(a.textUthmani);
      buf.write(' ۝${toArabicIndic(a.numberInSurah)} ');
      if (a.isSajdah) buf.write('۩ ');
    }
    final tp = TextPainter(
      text: TextSpan(
        text: buf.toString(),
        style: TextStyle(
          fontFamily: MobileMushafAyahText.fontFamily,
          fontFamilyFallback: MobileMushafAyahText.fontFamilyFallback,
          fontSize: fontSize,
          height: MobileMushafAyahText.ayahLineHeight,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      strutStyle: StrutStyle(
        fontFamily: MobileMushafAyahText.fontFamily,
        fontSize: fontSize,
        height: MobileMushafAyahText.ayahLineHeight,
        forceStrutHeight: true,
      ),
    )..layout(maxWidth: width);
    final h = tp.height;
    tp.dispose();
    return h;
  }
}

class _SurahBanner extends StatelessWidget {
  final int surahNumber;
  final ReadingPalette palette;
  final double fontSize;
  const _SurahBanner({
    required this.surahNumber,
    required this.palette,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Text(
        surahNameLigatureToken(surahNumber),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'SurahNames',
          fontSize: fontSize * 2.2,
          height: 1.0,
          color: palette.marker,
          fontFeatures: const [FontFeature.enable('liga')],
        ),
      ),
    );
  }
}
