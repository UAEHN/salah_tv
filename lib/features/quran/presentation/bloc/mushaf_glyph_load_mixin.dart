import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/i_mushaf_glyph_page_repository.dart';
import 'mushaf_reader_state.dart';

/// Pre-warms the v1 glyph page cache around the current page so PageView
/// peeks feel instant. Each visible Mushaf page renders itself through
/// [MobileMushafGlyphPageContainer], which calls the same repository —
/// the repo's in-memory cache hits the result we primed here.
mixin MushafGlyphLoadMixin on Cubit<MushafReaderState> {
  IMushafGlyphPageRepository get glyphRepoForMixin;

  Future<void> loadGlyphPage(int pageNumber) async {
    // Fire-and-forget: load this page and its two neighbours.
    glyphRepoForMixin.getPage(pageNumber);
    if (pageNumber > 1) glyphRepoForMixin.getPage(pageNumber - 1);
    if (pageNumber < 604) glyphRepoForMixin.getPage(pageNumber + 1);
  }
}
