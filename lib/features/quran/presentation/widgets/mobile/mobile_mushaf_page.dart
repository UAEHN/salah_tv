import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran;

import '../../../domain/entities/reading_theme.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import 'mobile_mushaf_glyph_page_view.dart';
import 'mobile_mushaf_page_header.dart';

/// One full page in the reader. Carries its own header so a swipe
/// never rebuilds a global AppBar, plus a [MobileMushafGlyphPageView]
/// for the body. `AutomaticKeepAliveClientMixin` retains the built
/// widget tree across swipes.
///
/// Audio-highlight: an inner `BlocBuilder` wraps only the glyph view.
/// `buildWhen` fires **only** when the playing verse moves into or out
/// of this page — visited-but-not-current pages never rebuild, and
/// even on the current page the header stays untouched.
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

  bool _versePinsHere(int? surah, int? ayah) {
    if (surah == null || ayah == null) return false;
    return quran.getPageNumber(surah, ayah) == widget.pageNumber;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: widget.palette.pageBg,
      child: Column(
        children: [
          // Notch / status-bar guard: pushes the header's icon row down
          // so the back / surah-index / settings buttons are reachable
          // and visible on phones with a top cutout.
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
            child: BlocBuilder<MushafReaderCubit, MushafReaderState>(
              buildWhen: (p, n) {
                // Rebuild on font-size slider change (every visible /
                // KeepAlive'd page must re-scale).
                if (p.fontSize != n.fontSize) return true;
                // Otherwise only rebuild when the playing verse moved
                // into or out of this page — visited pages don't pay
                // the cost when audio progresses elsewhere.
                final wasHere =
                    _versePinsHere(p.playingSurah, p.playingAyah);
                final nowHere =
                    _versePinsHere(n.playingSurah, n.playingAyah);
                return wasHere != nowHere ||
                    (nowHere &&
                        (p.playingSurah != n.playingSurah ||
                            p.playingAyah != n.playingAyah));
              },
              builder: (_, state) {
                final pvk = _versePinsHere(
                            state.playingSurah, state.playingAyah)
                        ? '${state.playingSurah}:${state.playingAyah}'
                        : null;
                // `MushafPreferences.fontSize` defaults to 26 — that is
                // 1.0 × printed-Mushaf size. Slider values above scale
                // up, below scale down.
                final fontScale = state.fontSize / 26.0;
                return MobileMushafGlyphPageView(
                  pageNumber: widget.pageNumber,
                  palette: widget.palette,
                  playingVerseKey: pvk,
                  fontScale: fontScale,
                  onAyahTap: widget.onAyahTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
