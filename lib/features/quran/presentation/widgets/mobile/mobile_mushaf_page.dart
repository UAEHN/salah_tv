import 'package:flutter/material.dart';

import '../../../domain/entities/reading_theme.dart';
import 'mobile_mushaf_image_page.dart';
import 'mobile_mushaf_page_header.dart';

/// One full page in the reader. Header on top + image-based Mushaf
/// page body. `AutomaticKeepAliveClientMixin` retains the built
/// widget tree across swipes so cached images don't re-decode.
///
/// Audio-highlight overlays will land here in Phase 2 (tap-to-play
/// via ayahinfo SQLite — see project_quran_engine_pivot memory).
class MobileMushafPage extends StatefulWidget {
  final int pageNumber;
  final ReadingPalette palette;
  final VoidCallback onBack;
  final VoidCallback onOpenSurahIndex;
  final VoidCallback onOpenPageJump;
  final VoidCallback onSaveBookmark;
  final VoidCallback onSettings;
  final VoidCallback onShowIntro;
  final void Function(int surah, int ayah) onAyahTap;

  const MobileMushafPage({
    super.key,
    required this.pageNumber,
    required this.palette,
    required this.onBack,
    required this.onOpenSurahIndex,
    required this.onOpenPageJump,
    required this.onSaveBookmark,
    required this.onSettings,
    required this.onShowIntro,
    required this.onAyahTap,
  });

  @override
  State<MobileMushafPage> createState() => _MobileMushafPageState();
}

class _MobileMushafPageState extends State<MobileMushafPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: widget.palette.pageBg,
      child: Column(
        children: [
          SafeArea(
            top: true,
            bottom: false,
            child: MobileMushafPageHeader(
              pageNumber: widget.pageNumber,
              palette: widget.palette,
              onBack: widget.onBack,
              onOpenSurahIndex: widget.onOpenSurahIndex,
              onOpenPageJump: widget.onOpenPageJump,
              onSaveBookmark: widget.onSaveBookmark,
              onSettings: widget.onSettings,
              onShowIntro: widget.onShowIntro,
            ),
          ),
          Expanded(
            child: MobileMushafImagePage(
              pageNumber: widget.pageNumber,
              palette: widget.palette,
              onAyahTap: widget.onAyahTap,
            ),
          ),
        ],
      ),
    );
  }
}
