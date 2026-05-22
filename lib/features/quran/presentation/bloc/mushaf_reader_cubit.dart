import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/available_ayah_reciters.dart';
import '../../domain/entities/mushaf_page.dart';
import '../../domain/entities/quran_bookmark.dart';
import '../../domain/i_ayah_audio_port.dart';
import '../../domain/i_mushaf_glyph_page_repository.dart';
import '../../domain/i_mushaf_preferences_repository.dart';
import '../../domain/i_quran_text_repository.dart';
import '../../domain/usecases/get_bookmark_usecase.dart';
import '../../domain/usecases/get_mushaf_page_usecase.dart';
import '../../domain/usecases/play_ayah_usecase.dart';
import '../../domain/usecases/quran_intro_usecases.dart';
import '../../domain/usecases/save_bookmark_usecase.dart';
import 'mushaf_audio_flow_mixin.dart';
import 'mushaf_bookmark_mixin.dart';
import 'mushaf_glyph_load_mixin.dart';
import 'mushaf_prefs_mixin.dart';
import 'mushaf_reader_state.dart';

class MushafReaderCubit extends Cubit<MushafReaderState>
    with MushafAudioFlowMixin, MushafPrefsMixin, MushafBookmarkMixin,
         MushafGlyphLoadMixin {
  final IQuranTextRepository _textRepo;
  final GetMushafPageUseCase _getPage;
  final GetBookmarkUseCase _getBookmark;
  final SaveBookmarkUseCase _saveBookmark;
  final PlayAyahUseCase _playAyah;
  final StopAyahAudioUseCase _stopAyah;
  final IAyahAudioPort _audioPort;
  final IMushafPreferencesRepository _prefsRepo;
  final IMushafGlyphPageRepository _glyphRepo;
  final HasSeenMushafIntroUseCase _hasSeenIntro;
  final MarkMushafIntroSeenUseCase _markIntroSeen;
  StreamSubscription<AyahPlaybackEvent>? _audioSub;

  MushafReaderCubit({
    required IQuranTextRepository textRepo,
    required GetMushafPageUseCase getPage,
    required GetBookmarkUseCase getBookmark,
    required SaveBookmarkUseCase saveBookmark,
    required PlayAyahUseCase playAyah,
    required StopAyahAudioUseCase stopAyah,
    required IAyahAudioPort audioPort,
    required IMushafPreferencesRepository prefsRepo,
    required IMushafGlyphPageRepository glyphRepo,
    required HasSeenMushafIntroUseCase hasSeenIntro,
    required MarkMushafIntroSeenUseCase markIntroSeen,
  })  : _textRepo = textRepo,
        _getPage = getPage,
        _getBookmark = getBookmark,
        _saveBookmark = saveBookmark,
        _playAyah = playAyah,
        _stopAyah = stopAyah,
        _audioPort = audioPort,
        _prefsRepo = prefsRepo,
        _glyphRepo = glyphRepo,
        _hasSeenIntro = hasSeenIntro,
        _markIntroSeen = markIntroSeen,
        super(const MushafReaderState()) {
    _audioSub = _audioPort.events.listen(onAudioEvent);
  }

  @override
  IQuranTextRepository get audioTextRepo => _textRepo;
  @override
  PlayAyahUseCase get audioPlayAyah => _playAyah;
  @override
  IMushafPreferencesRepository get prefsRepoForMixin => _prefsRepo;
  @override
  SaveBookmarkUseCase get bookmarkSaveForMixin => _saveBookmark;
  @override
  IMushafGlyphPageRepository get glyphRepoForMixin => _glyphRepo;
  @override
  Future<void> navigateToPageFromAudio(int p) => goToPage(p);

  Future<void> init() async {
    if (state.loadStatus == MushafLoadStatus.ready) {
      return emit(state.copyWith(bookmark: await _getBookmark()));
    }
    emit(state.copyWith(loadStatus: MushafLoadStatus.loading));
    final prefs = await _prefsRepo.load();
    final seenIntro = await _hasSeenIntro();
    final load = await _textRepo.ensureLoaded();
    if (load.isLeft()) {
      final msg = load.fold((f) => f.message, (_) => '');
      return emit(state.copyWith(
          loadStatus: MushafLoadStatus.error, loadError: msg));
    }
    emit(state.copyWith(
      loadStatus: MushafLoadStatus.ready,
      bookmark: await _getBookmark(),
      prefs: prefs,
      hasSeenIntro: seenIntro,
    ));
  }

  Future<void> markIntroSeen() async {
    if (state.hasSeenIntro) return;
    await _markIntroSeen();
    emit(state.copyWith(hasSeenIntro: true));
  }
  Future<void> openReader({int? page, QuranBookmark? resume}) async {
    await init();
    if (state.loadStatus != MushafLoadStatus.ready) return;
    final target = resume?.page ?? page ?? state.bookmark?.page ?? 1;
    await goToPage(target.clamp(1, MushafPage.totalPages));
  }
  Future<void> goToPage(int pageNumber) async {
    final clamped = pageNumber.clamp(1, MushafPage.totalPages);
    (await _getPage(clamped)).fold(
      (f) => emit(state.copyWith(loadError: f.message)),
      (page) {
        emit(state.copyWith(currentPage: clamped, currentPageData: page));
        scheduleBookmarkAutoSave();
        // Warm the glyph repo cache for the current page + its two
        // neighbours so the next swipe paints on the first frame
        // (sync-cache hit in MobileMushafGlyphPageContainer).
        loadGlyphPage(clamped);
      },
    );
  }
  Future<void> goToSurah(int surahNumber) async =>
      (await _textRepo.pageOfSurah(surahNumber)).fold(
        (f) async => emit(state.copyWith(loadError: f.message)),
        goToPage,
      );
  Future<void> tapAyah(int surah, int ayah) async {
    if (state.isAyahPlaying(surah, ayah)) return _audioPort.pause();
    if (state.isAyahPaused(surah, ayah)) return _audioPort.resume();
    await _playAyah(
        surahNumber: surah,
        ayahNumber: ayah,
        reciterUrlSegment: resolveReciter(state.prefs.reciterId).urlSegment);
  }
  Future<void> stopAudio() => _stopAyah();
  Future<void> onLeaveReader() async {
    cancelBookmarkAutoSave();
    await _stopAyah();
    await saveBookmark();
  }

  @override
  Future<void> close() async {
    cancelBookmarkAutoSave();
    await _audioSub?.cancel();
    await _stopAyah();
    return super.close();
  }
}
