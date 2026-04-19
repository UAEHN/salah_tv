import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Manages background Quran streaming from the mp3quran.net CDN.
/// Streams surah-by-surah (1→2→…→114→1) and handles pause/resume/restart.
class QuranAudioService {
  final AudioPlayer _quranPlayer = AudioPlayer();
  String _quranServerUrl = '';
  int _quranSurahIndex = 0; // 0-based (surah 1 = index 0)
  DateTime? _quranPausedAt; // tracks when Quran was paused (Issue 7)

  // Guards the onPlayerComplete listener against re-entrant double-fire.
  // On Android TV, onPlayerComplete can fire more than once per natural
  // completion. The flag is set to true in the listener before the async
  // _playCurrentSurah() call, then reset via whenComplete() so the NEXT
  // surah's completion is handled normally.
  //
  // Intentionally NOT checked inside _playCurrentSurah() itself — external
  // callers (playQuranFromServer, resumeOrRestartQuranPlayer, etc.) must
  // always be able to restart the player regardless of transition state.
  // Those callers reset _isTransitioning = false before stopping/restarting
  // so the listener guard is consistent.
  bool _isTransitioning = false;

  int get quranSurahIndex => _quranSurahIndex;

  QuranAudioService() {
    // When a surah finishes, advance to the next (1→2→…→114→1).
    // _isTransitioning prevents a double-fired completion event from
    // incrementing _quranSurahIndex twice and issuing two concurrent
    // play() calls that corrupt the ExoPlayer state over time.
    _quranPlayer.onPlayerComplete.listen((_) {
      if (_quranServerUrl.isNotEmpty && !_isTransitioning) {
        _isTransitioning = true;
        _quranSurahIndex = (_quranSurahIndex + 1) % 114;
        _playCurrentSurah().whenComplete(() => _isTransitioning = false);
      }
    });
  }

  /// Only allow HTTPS URLs from the trusted mp3quran.net CDN.
  static bool _isAllowedQuranUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.scheme == 'https' && uri.host.endsWith('mp3quran.net');
  }

  Future<void> _playCurrentSurah() async {
    if (_quranServerUrl.isEmpty) return;
    try {
      final surahNum = (_quranSurahIndex + 1).toString().padLeft(3, '0');
      final url = '$_quranServerUrl$surahNum.mp3';
      // Explicit stop before play releases the previous MediaSource on the
      // native ExoPlayer. Skipping it let decoders accumulate on TV boxes
      // across many surah transitions over multi-hour sessions.
      await _quranPlayer.stop();
      await _quranPlayer.setReleaseMode(ReleaseMode.release);
      await _quranPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('[QuranAudio] _playCurrentSurah failed: $e');
    }
  }

  /// Start streaming from the given CDN server URL, beginning at surah 1.
  Future<void> playQuranFromServer(String serverUrl) async {
    if (!_isAllowedQuranUrl(serverUrl)) return;
    _quranServerUrl = serverUrl;
    _quranSurahIndex = 0;
    _isTransitioning = false; // explicit restart: clear any in-flight guard
    await _quranPlayer.stop();
    await _playCurrentSurah();
  }

  /// Pause Quran (called automatically when adhan fires).
  Future<void> pauseQuranPlayer() async {
    _quranPausedAt = DateTime.now(); // record pause time for Issue 7 check
    try {
      await _quranPlayer.pause();
    } catch (e) {
      debugPrint('[QuranAudio] pauseQuranPlayer failed: $e');
    }
  }

  /// Resume or restart Quran after iqama ends (Issue 7).
  /// If paused >60s the HTTP stream will have timed out — restart from current surah.
  Future<void> resumeOrRestartQuranPlayer(String serverUrl) async {
    final pausedAt = _quranPausedAt;
    _quranPausedAt = null;
    final longPause =
        pausedAt != null &&
        DateTime.now().difference(pausedAt).inSeconds > 60;
    if (longPause) {
      _quranServerUrl = serverUrl;
      _isTransitioning = false; // explicit restart: clear any in-flight guard
      await _quranPlayer.stop();
      await _playCurrentSurah();
    } else {
      try {
        await _quranPlayer.resume();
      } catch (e) {
        debugPrint('[QuranAudio] resume after pause failed: $e');
      }
    }
  }

  /// Restart from the current surah position (fresh audio session).
  /// Used when returning from Makkah stream audio.
  Future<void> restartQuranCurrentSurah(String serverUrl) async {
    _quranPausedAt = null;
    if (!_isAllowedQuranUrl(serverUrl)) return;
    _quranServerUrl = serverUrl;
    _isTransitioning = false; // explicit restart: clear any in-flight guard
    await _quranPlayer.stop();
    await _playCurrentSurah();
  }

  /// Resume Quran. Prefer [resumeOrRestartQuranPlayer] for the adhan/iqama cycle.
  Future<void> resumeQuranPlayer() async {
    try {
      await _quranPlayer.resume();
    } catch (e) {
      debugPrint('[QuranAudio] resumeQuranPlayer failed: $e');
    }
  }

  /// Fully stop Quran (user pressed the stop button).
  Future<void> stopQuranPlayer() async {
    try {
      _isTransitioning = false; // reset guard: player is being fully stopped
      _quranServerUrl = '';
      _quranSurahIndex = 0;
      await _quranPlayer.stop();
    } catch (e) {
      debugPrint('[QuranAudio] stopQuranPlayer failed: $e');
    }
  }

  void dispose() => _quranPlayer.dispose();
}
