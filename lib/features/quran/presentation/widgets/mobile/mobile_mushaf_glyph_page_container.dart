import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../injection.dart';
import '../../../domain/entities/mushaf_glyph_page.dart';
import '../../../domain/entities/reading_theme.dart';
import '../../../domain/i_mushaf_glyph_page_repository.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import 'mobile_mushaf_glyph_page_view.dart';

/// Self-loading wrapper for one Mushaf v1 page. The `PageView.builder`
/// instantiates a container per index and the container resolves its
/// glyph data — preferring the repo's sync cache so already-warmed
/// pages render on the first frame. Adjacent pages are prewarmed by
/// the cubit's [MushafGlyphLoadMixin] so the typical swipe never hits
/// the async path. fontScale + playing-verse highlight are read from
/// the cubit here (not via widget props) so only the current container
/// rebuilds on those changes — the parent PageView stays stable.
///
/// This is the dedicated "bridge widget" that owns the repository
/// dependency, as allowed by CLAUDE.md §3.
class MobileMushafGlyphPageContainer extends StatefulWidget {
  /// Default font size (matches [MushafPreferences.fontSize] default). The
  /// glyph view is driven by a *scale factor*, not an absolute pixel
  /// size, so this constant maps the user's preferred font value back to
  /// `1.0 = printed-page proportions`.
  static const double baselineFontSize = 26.0;

  final int pageNumber;
  final ReadingPalette palette;
  final void Function(String verseKey)? onWordTap;

  const MobileMushafGlyphPageContainer({
    super.key,
    required this.pageNumber,
    required this.palette,
    this.onWordTap,
  });

  @override
  State<MobileMushafGlyphPageContainer> createState() =>
      _MobileMushafGlyphPageContainerState();
}

class _MobileMushafGlyphPageContainerState
    extends State<MobileMushafGlyphPageContainer> {
  MushafGlyphPage? _glyph;

  @override
  void initState() {
    super.initState();
    _resolve(widget.pageNumber);
  }

  @override
  void didUpdateWidget(covariant MobileMushafGlyphPageContainer old) {
    super.didUpdateWidget(old);
    if (old.pageNumber != widget.pageNumber) {
      _resolve(widget.pageNumber);
    }
  }

  void _resolve(int pageNumber) {
    final repo = getIt<IMushafGlyphPageRepository>();
    final hit = repo.cachedPage(pageNumber);
    if (hit != null) {
      _glyph = hit;
      return;
    }
    _glyph = null;
    _loadAsync(repo, pageNumber);
  }

  Future<void> _loadAsync(
      IMushafGlyphPageRepository repo, int pageNumber) async {
    final res = await repo.getPage(pageNumber);
    if (!mounted || widget.pageNumber != pageNumber) return;
    res.fold((_) {}, (page) => setState(() => _glyph = page));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MushafReaderCubit, MushafReaderState>(
      buildWhen: (a, b) =>
          a.fontSize != b.fontSize ||
          a.audioStatus != b.audioStatus ||
          a.playingSurah != b.playingSurah ||
          a.playingAyah != b.playingAyah,
      builder: (context, state) {
        final g = _glyph;
        if (g == null) {
          return Container(
            color: widget.palette.pageBg,
            alignment: Alignment.center,
            child: CircularProgressIndicator(color: widget.palette.marker),
          );
        }
        final fontScale =
            state.fontSize / MobileMushafGlyphPageContainer.baselineFontSize;
        final pvk = state.playingSurah != null && state.playingAyah != null
            ? '${state.playingSurah}:${state.playingAyah}'
            : null;
        return MobileMushafGlyphPageView(
          page: g,
          palette: widget.palette,
          playingVerseKey: pvk,
          fontScale: fontScale,
          onWordTap: widget.onWordTap,
        );
      },
    );
  }
}
