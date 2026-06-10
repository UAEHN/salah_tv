import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/available_ayah_reciters.dart';
import '../../domain/i_ayah_audio_port.dart';
import '../../domain/i_quran_text_repository.dart';
import '../../domain/usecases/play_ayah_usecase.dart';
import 'mushaf_reader_state.dart';

/// Audio-event reaction + continuous-playback chain — extracted from
/// [MushafReaderCubit] to keep that file under 150 lines per CLAUDE.md
/// §4. Mirrors the engine-mixin pattern used by `PrayerCycleEngine`.
///
/// The mixin owns the state transitions driven by audio events but
/// delegates page navigation back to the cubit via [navigateToPageFromAudio]
/// so paging logic stays in one place.
mixin MushafAudioFlowMixin on Cubit<MushafReaderState> {
  // Abstract accessors — supplied by the concrete cubit.
  IQuranTextRepository get audioTextRepo;
  PlayAyahUseCase get audioPlayAyah;
  Future<void> navigateToPageFromAudio(int pageNumber);

  void onAudioEvent(AyahPlaybackEvent ev) {
    switch (ev.status) {
      case AyahAudioStatus.loading:
        emit(
          state.copyWith(
            audioStatus: MushafAudioStatus.loading,
            playingSurah: ev.surahNumber,
            playingAyah: ev.ayahNumber,
          ),
        );
      case AyahAudioStatus.playing:
        emit(
          state.copyWith(
            audioStatus: MushafAudioStatus.playing,
            playingSurah: ev.surahNumber,
            playingAyah: ev.ayahNumber,
          ),
        );
      case AyahAudioStatus.paused:
        emit(state.copyWith(audioStatus: MushafAudioStatus.paused));
      case AyahAudioStatus.completed:
        _onAyahCompleted(ev.surahNumber, ev.ayahNumber);
      case AyahAudioStatus.idle:
        _emitIdle();
      case AyahAudioStatus.error:
        emit(
          state.copyWith(
            audioStatus: MushafAudioStatus.error,
            clearPlaying: true,
          ),
        );
    }
  }

  Future<void> _onAyahCompleted(int? s, int? a) async {
    if (!state.continuousPlayback || s == null || a == null) {
      _emitIdle();
      return;
    }
    final next = await audioTextRepo.nextAyah(s, a);
    if (next == null) {
      _emitIdle();
      return;
    }
    if (next.page != state.currentPage) {
      await navigateToPageFromAudio(next.page);
    }
    final reciter = resolveReciter(state.prefs.reciterId).urlSegment;
    await audioPlayAyah(
      surahNumber: next.surahNumber,
      ayahNumber: next.numberInSurah,
      reciterUrlSegment: reciter,
    );
  }

  void _emitIdle() => emit(
    state.copyWith(audioStatus: MushafAudioStatus.idle, clearPlaying: true),
  );
}
