import 'package:flutter/material.dart';

import '../../../domain/entities/ayah.dart';
import '../../../domain/entities/mushaf_page.dart';
import '../../../domain/entities/reading_theme.dart';
import 'mobile_mushaf_glyph_page_container.dart';

/// PageView block of the Mushaf reader. Each page is rendered with its
/// dedicated Mushaf v1 TTF (printed Madinah layout, 15 lines per body
/// page) — the natural Mushaf experience. Default = full page, no
/// scroll. The font slider zooms the page; when zoomed the glyph view
/// switches into a 2D-scrollable surface so the reader can pan.
///
/// Intentionally takes no state snapshot — fontScale, playing-verse
/// highlight and theme are read by the per-page container so a state
/// change never rebuilds the PageView itself (which would interrupt
/// the swipe gesture).
class MobileMushafReaderPages extends StatelessWidget {
  final ReadingPalette palette;
  final PageController controller;
  final void Function(int) onPageChanged;
  final void Function(Ayah) onAyahTap;

  const MobileMushafReaderPages({
    super.key,
    required this.palette,
    required this.controller,
    required this.onPageChanged,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      reverse: true,
      itemCount: MushafPage.totalPages,
      onPageChanged: onPageChanged,
      itemBuilder: (_, i) => MobileMushafGlyphPageContainer(
        pageNumber: i + 1,
        palette: palette,
        onWordTap: (verseKey) => _routeWordTap(verseKey, onAyahTap),
      ),
    );
  }

  /// Map a v1 word tap (`"surah:ayah"`) back to the existing per-Ayah
  /// flow. We parse the integers from the key directly — no MushafPage
  /// lookup required, which lets each PageView item render fully
  /// independently of the cubit's currently-cached page data.
  void _routeWordTap(String verseKey, void Function(Ayah) onAyahTap) {
    final parts = verseKey.split(':');
    if (parts.length != 2) return;
    final s = int.tryParse(parts[0]);
    final a = int.tryParse(parts[1]);
    if (s == null || a == null) return;
    onAyahTap(Ayah(
      surahNumber: s,
      numberInSurah: a,
      page: 0,
      juz: 0,
      textUthmani: '',
      isFirstAyahOfSurah: false,
    ));
  }
}
