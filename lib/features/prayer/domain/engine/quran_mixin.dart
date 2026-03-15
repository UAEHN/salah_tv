import 'prayer_cycle_base.dart';

/// Manages Quran background audio: user toggle, pause/resume around the adhan
/// cycle, and Makkah stream audio coordination.
mixin QuranMixin on PrayerCycleBase {
  /// Toggle Quran streaming on/off.
  /// [serverUrl] is the CDN URL from mp3quran.net (e.g. 'https://server8.mp3quran.net/maher/')
  void toggleQuran(String? serverUrl) {
    if (s.isQuranPlaying) {
      s.isQuranPlaying = false;
      s.isQuranPausedForAdhan = false;
      audio.stopQuranPlayer();
    } else {
      if (serverUrl == null || serverUrl.isEmpty) return;
      s.isQuranPlaying = true;
      s.isQuranPausedForAdhan = false;
      audio.playQuranFromServer(serverUrl); // async, fire-and-forget
    }
    notify();
  }

  /// Pause Quran when adhan starts (internal, auto-resumes after iqama).
  void pauseQuranForAdhan() {
    if (s.isQuranPlaying && !s.isQuranPausedForAdhan) {
      s.isQuranPausedForAdhan = true;
      audio.pauseQuranPlayer();
    }
  }

  /// Resume Quran after iqama ends (internal).
  /// Issue 7: uses resumeOrRestartQuranPlayer so a timed-out HTTP stream is
  /// restarted from the current surah rather than silently producing no audio.
  void resumeQuranAfterAdhan() {
    if (s.isQuranPausedForAdhan) {
      s.isQuranPausedForAdhan = false;
      // Don't resume Quran if Makkah stream audio is still active
      if (s.isMakkahStreamAudioActive) return;
      audio.resumeOrRestartQuranPlayer(settings.quranReciterServerUrl);
    }
  }

  /// Called by the Makkah stream widget when stream audio starts/stops.
  /// Mirrors the Quran pause/resume pattern used during the adhan cycle.
  void setMakkahStreamAudioActive(bool value) {
    if (s.isMakkahStreamAudioActive == value) return;
    s.isMakkahStreamAudioActive = value;
    if (value) {
      // Stream audio turning on — pause Quran if it is currently playing
      if (s.isQuranPlaying && !s.isQuranPausedForAdhan) {
        audio.pauseQuranPlayer();
      }
    } else {
      // Stream audio turning off — restart Quran from current surah.
      // Always restart (not resume) because ExoPlayer may have caused the
      // audioplayer to lose its paused state via Android audio focus changes.
      if (s.isQuranPlaying && !s.isQuranPausedForAdhan) {
        audio.restartQuranCurrentSurah(settings.quranReciterServerUrl);
      }
    }
    // No notify() here — no widget watches isMakkahStreamAudioActive.
    // Calling it caused a redundant notifyListeners() rebuild cascade that
    // starved the 1-second tick timer on slow TV hardware.
  }
}
