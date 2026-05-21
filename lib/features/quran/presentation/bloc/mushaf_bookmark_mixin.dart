import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ayah.dart';
import '../../domain/entities/mushaf_page.dart';
import '../../domain/entities/quran_bookmark.dart';
import '../../domain/usecases/save_bookmark_usecase.dart';
import 'mushaf_reader_state.dart';

/// Bookmark write-path split off from [MushafReaderCubit] so the cubit
/// stays under the 150-line cap (CLAUDE.md §4). Owns:
///   - the debounced auto-save timer (survives crashes between page turns)
///   - the resume-anchor rule (prefer the playing ayah over page-start)
///   - the canonical save + cancellation surface used by the cubit.
mixin MushafBookmarkMixin on Cubit<MushafReaderState> {
  SaveBookmarkUseCase get bookmarkSaveForMixin;

  Timer? _autoSaveDebounce;
  static const _autoSaveDelay = Duration(seconds: 2);

  void scheduleBookmarkAutoSave() {
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = Timer(_autoSaveDelay, saveBookmark);
  }

  void cancelBookmarkAutoSave() => _autoSaveDebounce?.cancel();

  Future<void> saveBookmark() async {
    final page = state.currentPageData;
    if (page == null || page.ayahs.isEmpty) return;
    final anchor = _resumeAnchor(page);
    final bookmark = QuranBookmark(
      page: page.pageNumber,
      surahNumber: anchor.surahNumber,
      ayahNumber: anchor.numberInSurah,
      savedAt: DateTime.now(),
    );
    await bookmarkSaveForMixin(bookmark);
    emit(state.copyWith(bookmark: bookmark));
  }

  // Pick the most meaningful resume point on the page: the ayah the user
  // is actively listening to (if any), otherwise the first ayah on page.
  Ayah _resumeAnchor(MushafPage page) {
    final s = state.playingSurah;
    final a = state.playingAyah;
    if (state.isAudioActive && s != null && a != null) {
      for (final x in page.ayahs) {
        if (x.surahNumber == s && x.numberInSurah == a) return x;
      }
    }
    return page.ayahs.first;
  }
}
