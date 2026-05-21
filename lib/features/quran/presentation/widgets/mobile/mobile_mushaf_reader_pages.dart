import 'package:flutter/material.dart';
import '../../../domain/entities/ayah.dart';
import '../../../domain/entities/mushaf_page.dart';
import '../../../domain/entities/reading_theme.dart';
import '../../bloc/mushaf_reader_state.dart';
import 'mobile_mushaf_page_view.dart';

/// PageView block of the Mushaf reader. Extracted from the reader screen
/// to keep that file under the 150-line cap (CLAUDE.md §4).
class MobileMushafReaderPages extends StatelessWidget {
  final MushafReaderState state;
  final ReadingPalette palette;
  final PageController controller;
  final void Function(int) onPageChanged;
  final void Function(Ayah) onAyahTap;

  const MobileMushafReaderPages({
    super.key,
    required this.state,
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
      itemBuilder: (_, i) {
        final page = state.currentPageData;
        if (page == null || page.pageNumber != i + 1) {
          return Center(
            child: CircularProgressIndicator(color: palette.marker),
          );
        }
        return MobileMushafPageView(
          page: page,
          state: state,
          onAyahTap: onAyahTap,
        );
      },
    );
  }
}
