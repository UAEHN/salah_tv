import '../../../quran/domain/entities/quran_playback_mode.dart';
import 'continuous_mode_mixin.dart';
import 'prayer_cycle_base.dart';

/// Manages Quran background audio across three independent playback modes.
///   • continuous   → see [ContinuousModeMixin] (start mode + random resolver)
///   • singleSurah  → repeats the chosen surah [surahRepeatCount] times, stops
///   • playlist     → iterates [playlistCycleCount] cycles, then stops
mixin QuranMixin on PrayerCycleBase, ContinuousModeMixin {
  /// Toggle Quran on/off using current settings to choose mode.
  void toggleQuran(String? serverUrl) {
    if (s.isQuranPlaying) {
      _stopAndClear();
      notify();
      return;
    }
    if (serverUrl == null || serverUrl.isEmpty) return;
    s.isQuranPlaying = true;
    s.isQuranPausedForAdhan = false;
    _startForCurrentMode(serverUrl);
    notify();
  }

  /// Pause Quran when adhan starts (auto-resumes after iqama).
  void pauseQuranForAdhan() {
    if (s.isQuranPlaying && !s.isQuranPausedForAdhan) {
      s.isQuranPausedForAdhan = true;
      audio.pauseQuranPlayer();
    }
  }

  /// Resume Quran after iqama ends. Issue 7: uses resumeOrRestartQuranPlayer
  /// so a timed-out HTTP stream restarts from the current surah.
  void resumeQuranAfterAdhan() {
    if (s.isQuranPausedForAdhan) {
      s.isQuranPausedForAdhan = false;
      audio.resumeOrRestartQuranPlayer(settings.quranReciterServerUrl);
    }
  }

  /// Called by engine when a surah finishes naturally.
  void onSurahCompleted(int finishedSurahNumber) {
    s.currentSurahNumber = audio.currentQuranSurah;
    if (s.currentSurahNumber == null && s.isQuranPlaying) {
      // Resolver returned null → finite count/cycles exhausted. Stop.
      _stopAndClear();
    }
    notify();
  }

  /// Manually skip to the next surah in the playlist.
  void skipToNextSurah() {
    if (!s.isQuranPlaying) return;
    if (settings.quranPlaybackMode != QuranPlaybackMode.playlist) return;
    final order = s.playlistOrder;
    if (order.length < 2) return;
    s.playlistCursor = (s.playlistCursor + 1) % order.length;
    audio.playQuranSurah(settings.quranReciterServerUrl, order[s.playlistCursor]);
    s.currentSurahNumber = audio.currentQuranSurah;
    notify();
  }

  // ── Mode dispatch ──────────────────────────────────────────────────────

  void _startForCurrentMode(String serverUrl) {
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

  // ── Resolvers ──────────────────────────────────────────────────────────

  int? _singleSurahResolver(int finishedSurah) {
    s.surahPlayCount++;
    final target = settings.surahRepeatCount;
    if (target == kInfiniteRepeat) return finishedSurah;
    if (s.surahPlayCount < target) return finishedSurah;
    return null; // exhausted → end action applied via onSurahCompleted
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
      return null; // exhausted
    }
    s.playlistCursor = 0;
    return s.playlistOrder.first;
  }

  void _switchToContinuous(String serverUrl) {
    if (serverUrl.isEmpty) {
      _stopAndClear();
      return;
    }
    startContinuousMode(serverUrl);
    s.currentSurahNumber = audio.currentQuranSurah;
  }

  void _stopAndClear() {
    s.isQuranPlaying = false;
    s.isQuranPausedForAdhan = false;
    s.currentSurahNumber = null;
    s.playlistCursor = 0;
    s.playlistCyclesCompleted = 0;
    s.surahPlayCount = 0;
    audio.setQuranNextSurahResolver(null);
    audio.stopQuranPlayer();
  }
}
