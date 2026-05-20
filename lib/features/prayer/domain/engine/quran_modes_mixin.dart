import '../../../quran/domain/entities/quran_playback_mode.dart';
import 'continuous_mode_mixin.dart';
import 'prayer_cycle_base.dart';

/// Playback-mode dispatch and per-mode resolvers, plus the canonical
/// stop-and-clear teardown. Split out of [QuranMixin] to keep each file under
/// the 150-line cap. Cross-mixin entry points are non-underscored
/// (`startQuranForCurrentMode`, `stopAndClearQuranPlayback`) per the
/// engine convention.
mixin QuranModesMixin on PrayerCycleBase, ContinuousModeMixin {
  void startQuranForCurrentMode(String serverUrl) {
    s.surahPlayCount = 0;
    s.playlistCyclesCompleted = 0;
    switch (settings.quranPlaybackMode) {
      case QuranPlaybackMode.continuous:
        startContinuousMode(serverUrl);
        break;
      case QuranPlaybackMode.singleSurah:
        _startSingleSurahMode(serverUrl);
        break;
      case QuranPlaybackMode.playlist:
        _startPlaylistMode(serverUrl);
        break;
    }
    s.currentSurahNumber = audio.currentQuranSurah;
  }

  void stopAndClearQuranPlayback() {
    s.isQuranPlaying = false;
    s.isQuranPausedForAdhan = false;
    s.isQuranPausedByUser = false;
    s.currentSurahNumber = null;
    s.playlistCursor = 0;
    s.playlistCyclesCompleted = 0;
    s.surahPlayCount = 0;
    audio.setQuranNextSurahResolver(null);
    audio.stopQuranPlayer();
  }

  void _startSingleSurahMode(String serverUrl) {
    final selected = settings.selectedSurahNumber;
    if (selected == null || selected < 1 || selected > 114) {
      _switchToContinuous(serverUrl);
      return;
    }
    audio.setQuranNextSurahResolver(_singleSurahResolver);
    audio.playQuranSurah(serverUrl, selected);
  }

  void _startPlaylistMode(String serverUrl) {
    final base = settings.surahPlaylist;
    if (base.isEmpty) {
      _switchToContinuous(serverUrl);
      return;
    }
    s.playlistOrder = base;
    s.playlistCursor = 0;
    audio.setQuranNextSurahResolver(_playlistResolver);
    audio.playQuranSurah(serverUrl, s.playlistOrder.first);
  }

  void _switchToContinuous(String serverUrl) {
    if (serverUrl.isEmpty) {
      stopAndClearQuranPlayback();
      return;
    }
    startContinuousMode(serverUrl);
    s.currentSurahNumber = audio.currentQuranSurah;
  }

  int? _singleSurahResolver(int finishedSurah) {
    s.surahPlayCount++;
    final target = settings.surahRepeatCount;
    if (target == kInfiniteRepeat) return finishedSurah;
    if (s.surahPlayCount < target) return finishedSurah;
    return null;
  }

  int? _playlistResolver(int finishedSurah) {
    final order = s.playlistOrder;
    if (order.isEmpty) return null;
    s.playlistCursor++;
    if (s.playlistCursor < order.length) {
      return order[s.playlistCursor];
    }
    s.playlistCyclesCompleted++;
    final target = settings.playlistCycleCount;
    if (target != kInfiniteRepeat &&
        s.playlistCyclesCompleted >= target) {
      return null;
    }
    s.playlistCursor = 0;
    return s.playlistOrder.first;
  }
}
