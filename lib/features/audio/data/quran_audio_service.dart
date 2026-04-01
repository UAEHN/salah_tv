import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Manages background Quran streaming from the mp3quran.net CDN.
/// Streams surah-by-surah (1→2→…→114→1) and handles pause/resume/restart.
class QuranAudioService {
  final AudioPlayer _quranPlayer = AudioPlayer();
  String _quranServerUrl = '';
  int _quranSurahIndex = 0; // 0-based (surah 1 = index 0)
  DateTime? _quranPausedAt; // tracks when Quran was paused (Issue 7)

  int get quranSurahIndex => _quranSurahIndex;

  QuranAudioService() {
    // When a surah finishes, advance to the next (1→2→…→114→1)
    _quranPlayer.onPlayerComplete.listen((_) {
      if (_quranServerUrl.isNotEmpty) {
        _quranSurahIndex = (_quranSurahIndex + 1) % 114;
        _playCurrentSurah();
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
      _quranServerUrl = '';
      _quranSurahIndex = 0;
      await _quranPlayer.stop();
    } catch (e) {
      debugPrint('[QuranAudio] stopQuranPlayer failed: $e');
    }
  }

  void dispose() => _quranPlayer.dispose();
}
