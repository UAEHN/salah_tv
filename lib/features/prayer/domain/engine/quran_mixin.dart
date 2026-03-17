import 'prayer_cycle_base.dart';

/// Manages Quran background audio: user toggle, pause/resume around the adhan cycle.
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
      audio.resumeOrRestartQuranPlayer(settings.quranReciterServerUrl);
    }
  }
}
