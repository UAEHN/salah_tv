import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../prayer/domain/i_prayer_audio_port.dart' show NextSurahResolver;
import 'quran_fade_controller.dart';

/// Background Quran streaming from the mp3quran.net CDN. Default mode is
/// continuous (1→2→…→114→1); a [NextSurahResolver] overrides for repeat/playlist.
class QuranAudioService {
  final AudioPlayer _quranPlayer = AudioPlayer();
  final StreamController<int> _surahCompletedCtrl =
      StreamController<int>.broadcast();
  String _quranServerUrl = '';
  int _quranSurahIndex = 0; // 0-based (surah 1 = index 0)
  DateTime? _quranPausedAt; // Issue 7: tracks when Quran was paused
  NextSurahResolver? _nextSurahResolver;
  late final QuranFadeController _fade = QuranFadeController(_quranPlayer);
  // Guards onPlayerComplete against re-entrant double-fire on Android TV.
  bool _isTransitioning = false;

  int get quranSurahIndex => _quranSurahIndex;
  int? get currentSurahNumber =>
      _quranServerUrl.isEmpty ? null : _quranSurahIndex + 1;
  Stream<int> get onSurahCompleted => _surahCompletedCtrl.stream;
  void setNextSurahResolver(NextSurahResolver? resolver) =>
      _nextSurahResolver = resolver;

  QuranAudioService() {
    _quranPlayer.onPlayerComplete.listen((_) {
      if (_quranServerUrl.isEmpty || _isTransitioning) return;
      final completedSurahNumber = _quranSurahIndex + 1;
      _surahCompletedCtrl.add(completedSurahNumber);
      _isTransitioning = true;
      final resolver = _nextSurahResolver;
      final nextNumber = resolver == null
          ? ((_quranSurahIndex + 1) % 114) +
                1 // default rolling (1..114)
          : resolver(completedSurahNumber);
      if (nextNumber == null || nextNumber < 1 || nextNumber > 114) {
        _quranServerUrl = '';
        _quranSurahIndex = 0;
        _isTransitioning = false;
        return;
      }
      _quranSurahIndex = nextNumber - 1;
      _playCurrentSurah().whenComplete(() => _isTransitioning = false);
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
      // Explicit stop releases the previous MediaSource on native ExoPlayer.
      await _quranPlayer.stop();
      await _quranPlayer.setReleaseMode(ReleaseMode.release);
      await _fade.applyImmediate(0.0);
      await _quranPlayer.play(UrlSource(url));
      unawaited(_fade.rampTo(1.0));
    } catch (e) {
      debugPrint('[QuranAudio] _playCurrentSurah failed: $e');
    }
  }

  Future<void> playQuranFromServer(String serverUrl) => playSurah(serverUrl, 1);

  Future<void> playSurah(String serverUrl, int surahNumber) async {
    if (!_isAllowedQuranUrl(serverUrl)) return;
    if (surahNumber < 1 || surahNumber > 114) return;
    _quranServerUrl = serverUrl;
    _quranSurahIndex = surahNumber - 1;
    _isTransitioning = false;
    _quranPausedAt = null;
    await _quranPlayer.stop();
    await _playCurrentSurah();
  }

  Future<void> pauseQuranPlayer() async {
    _quranPausedAt = DateTime.now(); // Issue 7
    try {
      await _quranPlayer.pause();
    } catch (e) {
      debugPrint('[QuranAudio] pauseQuranPlayer failed: $e');
    }
  }

  /// Issue 7: if paused >60s the HTTP stream timed out — restart current surah.
  Future<void> resumeOrRestartQuranPlayer(String serverUrl) async {
    final pausedAt = _quranPausedAt;
    _quranPausedAt = null;
    final longPause =
        pausedAt != null && DateTime.now().difference(pausedAt).inSeconds > 60;
    if (longPause) return restartQuranCurrentSurah(serverUrl);
    try {
      await _quranPlayer.resume();
    } catch (e) {
      debugPrint('[QuranAudio] resume after pause failed: $e');
    }
  }

  Future<void> restartQuranCurrentSurah(String serverUrl) async {
    _quranPausedAt = null;
    if (!_isAllowedQuranUrl(serverUrl)) return;
    _quranServerUrl = serverUrl;
    _isTransitioning = false;
    await _quranPlayer.stop();
    await _playCurrentSurah();
  }

  Future<void> resumeQuranPlayer() async {
    try {
      await _quranPlayer.resume();
    } catch (e) {
      debugPrint('[QuranAudio] resumeQuranPlayer failed: $e');
    }
  }

  Future<void> stopQuranPlayer() async {
    try {
      _isTransitioning = false;
      _quranServerUrl = '';
      _quranSurahIndex = 0;
      await _fade.rampTo(0.0, total: const Duration(milliseconds: 700));
      await _quranPlayer.stop();
    } catch (e) {
      debugPrint('[QuranAudio] stopQuranPlayer failed: $e');
    }
  }

  void dispose() {
    _surahCompletedCtrl.close();
    _quranPlayer.dispose();
  }
}
