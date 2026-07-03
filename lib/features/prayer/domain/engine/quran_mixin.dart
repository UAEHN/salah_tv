import 'continuous_mode_mixin.dart';
import 'engine_telemetry_extension.dart';
import 'prayer_cycle_base.dart';
import 'quran_modes_mixin.dart';

/// Manages Quran background audio across three independent playback modes.
///   • continuous   → see [ContinuousModeMixin] (start mode + random resolver)
///   • singleSurah  → repeats the chosen surah [surahRepeatCount] times, stops
///   • playlist     → iterates [playlistCycleCount] cycles, then stops
/// Mode dispatch / resolvers / teardown live in [QuranModesMixin].
mixin QuranMixin on PrayerCycleBase, ContinuousModeMixin, QuranModesMixin {
  /// Tri-state toggle:
  ///  • playing       → user-pause (audio paused, surah/cursor preserved)
  ///  • user-paused   → user-resume (resumes the same surah; restarts the
  ///                    HTTP stream if it timed out — Issue 7)
  ///  • stopped       → fresh start in the configured playback mode
  ///
  /// Paused-by-adhan is owned by the cycle; toggle is a no-op in that state.
  /// How long the Quran network-error banner stays up before the tick clears
  /// it. Long enough to read on a TV across the room, short enough not to linger.
  static const Duration _kQuranErrorWindow = Duration(seconds: 10);

  /// Records a Quran load/play failure so the home screen can show a non-silent
  /// message. Ignored when the user has Quran off (nothing was meant to play).
  void markQuranError() {
    if (!s.isQuranPlaying) return;
    s.quranErrorAt = s.now;
    notify();
  }

  /// Mirrors the audio layer's loading/buffering signal into state. Clears any
  /// error banner when loading resumes (the stream is alive again).
  void setQuranLoading(bool loading) {
    if (loading) s.quranErrorAt = null;
    if (s.isQuranLoading == loading) return;
    s.isQuranLoading = loading;
    notify();
  }

  /// Clears the error banner once its display window elapses. Called from tick.
  void clearStaleQuranError() {
    final at = s.quranErrorAt;
    if (at == null) return;
    if (s.now.difference(at) >= _kQuranErrorWindow) {
      s.quranErrorAt = null;
      notify();
    }
  }

  void toggleQuran(String? serverUrl) {
    s.quranErrorAt = null; // any user interaction dismisses the error banner
    if (s.isQuranPausedForAdhan) return;
    if (s.isQuranPausedByUser) {
      _resumeByUser(serverUrl);
      notify();
      return;
    }
    if (s.isQuranPlaying) {
      _pauseByUser();
      notify();
      return;
    }
    if (serverUrl == null || serverUrl.isEmpty) return;
    s.isQuranPlaying = true;
    s.isQuranPausedForAdhan = false;
    s.isQuranPausedByUser = false;
    startQuranForCurrentMode(serverUrl);
    notify();
  }

  /// Hard stop used by settings changes (mode/reciter switch). Bypasses the
  /// user-pause branch of [toggleQuran].
  void stopQuranAndClear() => stopAndClearQuranPlayback();

  void _pauseByUser() {
    s.isQuranPausedByUser = true;
    audio.pauseQuranPlayer();
  }

  void _resumeByUser(String? serverUrl) {
    final url = (serverUrl == null || serverUrl.isEmpty)
        ? settings.quranReciterServerUrl
        : serverUrl;
    if (url.isEmpty) return;
    s.isQuranPausedByUser = false;
    audio.resumeOrRestartQuranPlayer(url);
  }

  /// Pause Quran when adhan starts (auto-resumes after iqama).
  /// User-pause takes precedence: nothing to pause if user already paused.
  void pauseQuranForAdhan() {
    if (s.isQuranPausedByUser) return;
    if (s.isQuranPlaying && !s.isQuranPausedForAdhan) {
      s.isQuranPausedForAdhan = true;
      telQuranPausedForCycle('adhan_trigger');
      audio.pauseQuranPlayer();
    }
  }

  /// Resume Quran after iqama ends. Issue 7: uses resumeOrRestartQuranPlayer
  /// so a timed-out HTTP stream restarts from the current surah.
  /// Skips resume if the user manually paused before/during the cycle.
  void resumeQuranAfterAdhan() {
    if (s.isQuranPausedForAdhan) {
      s.isQuranPausedForAdhan = false;
      if (s.isQuranPausedByUser) return;
      telQuranResumedAfterCycle();
      audio.resumeOrRestartQuranPlayer(settings.quranReciterServerUrl);
    }
  }

  /// Called by engine when a surah finishes naturally.
  void onSurahCompleted(int finishedSurahNumber) {
    s.currentSurahNumber = audio.currentQuranSurah;
    if (s.currentSurahNumber == null && s.isQuranPlaying) {
      // Resolver returned null → finite count/cycles exhausted. Stop.
      stopAndClearQuranPlayback();
    }
    notify();
  }
}
