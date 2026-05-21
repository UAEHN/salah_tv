import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/available_ayah_reciters.dart';
import '../../domain/entities/mushaf_page.dart';
import '../../domain/entities/quran_bookmark.dart';
import '../../domain/i_ayah_audio_port.dart';
import '../../domain/i_mushaf_preferences_repository.dart';
import '../../domain/i_quran_text_repository.dart';
import '../../domain/usecases/get_bookmark_usecase.dart';
import '../../domain/usecases/get_mushaf_page_usecase.dart';
import '../../domain/usecases/play_ayah_usecase.dart';
import '../../domain/usecases/save_bookmark_usecase.dart';
import 'mushaf_audio_flow_mixin.dart';
import 'mushaf_prefs_mixin.dart';
import 'mushaf_reader_state.dart';

class MushafReaderCubit extends Cubit<MushafReaderState>
    with MushafAudioFlowMixin, MushafPrefsMixin {
  final IQuranTextRepository _textRepo;
  final GetMushafPageUseCase _getPage;
  final GetBookmarkUseCase _getBookmark;
  final SaveBookmarkUseCase _saveBookmark;
  final PlayAyahUseCase _playAyah;
  final StopAyahAudioUseCase _stopAyah;
  final IAyahAudioPort _audioPort;
  final IMushafPreferencesRepository _prefsRepo;
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
  })  : _textRepo = textRepo,
        _getPage = getPage,
        _getBookmark = getBookmark,
        _saveBookmark = saveBookmark,
        _playAyah = playAyah,
        _stopAyah = stopAyah,
        _audioPort = audioPort,
        _prefsRepo = prefsRepo,
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
  Future<void> navigateToPageFromAudio(int page) => goToPage(page);

  Future<void> init() async {
    if (state.loadStatus == MushafLoadStatus.ready) {
      final b = await _getBookmark();
      emit(state.copyWith(bookmark: b));
      return;
    }
    emit(state.copyWith(loadStatus: MushafLoadStatus.loading));
    final prefs = await _prefsRepo.load();
    final load = await _textRepo.ensureLoaded();
    final ok = load.fold((f) {
      emit(state.copyWith(
        loadStatus: MushafLoadStatus.error,
        loadError: f.message,
      ));
      return false;
    }, (_) => true);
    if (!ok) return;
    final bookmark = await _getBookmark();
    emit(state.copyWith(
      loadStatus: MushafLoadStatus.ready,
      bookmark: bookmark,
      prefs: prefs,
    ));
  }

  Future<void> openReader({int? page, QuranBookmark? resume}) async {
    await init();
    if (state.loadStatus != MushafLoadStatus.ready) return;
    final target = resume?.page ?? page ?? state.bookmark?.page ?? 1;
    await goToPage(target.clamp(1, MushafPage.totalPages));
  }

  Future<void> goToPage(int pageNumber) async {
    final clamped = pageNumber.clamp(1, MushafPage.totalPages);
    final result = await _getPage(clamped);
    result.fold(
      (f) => emit(state.copyWith(loadError: f.message)),
      (page) => emit(state.copyWith(
        currentPage: clamped,
        currentPageData: page,
      )),
    );
  }

  Future<void> goToSurah(int surahNumber) async {
    final p = await _textRepo.pageOfSurah(surahNumber);
    await p.fold(
      (f) async => emit(state.copyWith(loadError: f.message)),
      (page) => goToPage(page),
    );
  }

  Future<void> tapAyah(int surah, int ayah) async {
    if (state.isAyahPlaying(surah, ayah)) return _audioPort.pause();
    if (state.isAyahPaused(surah, ayah)) return _audioPort.resume();
    await _playAyah(
      surahNumber: surah,
      ayahNumber: ayah,
      reciterUrlSegment: resolveReciter(state.prefs.reciterId).urlSegment,
    );
  }

  Future<void> stopAudio() => _stopAyah();
  Future<void> saveBookmark() async {
    final page = state.currentPageData;
    if (page == null || page.ayahs.isEmpty) return;
    final first = page.ayahs.first;
    final bookmark = QuranBookmark(
      page: page.pageNumber,
      surahNumber: first.surahNumber,
      ayahNumber: first.numberInSurah,
      savedAt: DateTime.now(),
    );
    await _saveBookmark(bookmark);
    emit(state.copyWith(bookmark: bookmark));
  }

  Future<void> onLeaveReader() async {
    await _stopAyah();
    await saveBookmark();
  }

  @override
  Future<void> close() async {
    await _audioSub?.cancel();
    await _stopAyah();
    return super.close();
  }
}
