import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../prayer/domain/i_prayer_audio_port.dart' show NextSurahResolver;
import 'quran_fade_controller.dart';

/// Background Quran streaming from the mp3quran.net CDN. Default mode is
/// continuous (1→2→…→114→1); a [NextSurahResolver] overrides for repeat/playlist.
///
/// Uses `just_audio` (ExoPlayer/media3 on Android) rather than `audioplayers`
/// for one reason: ExoPlayer prepares AND tears down the network source on
/// background threads, so stop()/setUrl never block the UI thread. The old
/// MediaPlayer path called `reset()` on the main thread, which waited on the
/// HTTPS connection's `disconnect()` and froze the app (ANR) whenever the CDN
/// stalled mid-stream.
class QuranAudioService {
  final AudioPlayer _quranPlayer = AudioPlayer();
  final StreamController<int> _surahCompletedCtrl =
      StreamController<int>.broadcast();
  String _quranServerUrl = '';
  int _quranSurahIndex = 0; // 0-based (surah 1 = index 0)
  DateTime? _quranPausedAt; // Issue 7: tracks when Quran was paused
  NextSurahResolver? _nextSurahResolver;
  late final QuranFadeController _fade = QuranFadeController(_quranPlayer);
  // Guards completion against re-entrant double-fire on Android TV.
  bool _isTransitioning = false;
  // Network load guard: a hung CDN must never stall the prayer cycle.
  static const _loadTimeout = Duration(seconds: 20);

  int get quranSurahIndex => _quranSurahIndex;
  int? get currentSurahNumber =>
      _quranServerUrl.isEmpty ? null : _quranSurahIndex + 1;
  Stream<int> get onSurahCompleted => _surahCompletedCtrl.stream;
  void setNextSurahResolver(NextSurahResolver? resolver) =>
      _nextSurahResolver = resolver;

  QuranAudioService() {
    // just_audio signals end-of-track via ProcessingState.completed (the
    // equivalent of audioplayers' onPlayerComplete).
    _quranPlayer.processingStateStream.listen((state) {
      if (state != ProcessingState.completed) return;
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
      await _quranPlayer.stop();
      await _fade.applyImmediate(0.0);
      // setUrl loads on a background thread; timeout guards a hung CDN load.
      await _quranPlayer.setUrl(url).timeout(_loadTimeout);
      // play() resolves only when playback ends, so it must not be awaited.
      unawaited(_quranPlayer.play());
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
    // play() resolves only at end-of-track, so start it without awaiting and
    // route any failure to the log instead of an unhandled future error.
    unawaited(
      _quranPlayer.play().catchError(
        (Object e) => debugPrint('[QuranAudio] resume after pause failed: $e'),
      ),
    );
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
    // play() resolves only at end-of-track — start without awaiting.
    unawaited(
      _quranPlayer.play().catchError(
        (Object e) => debugPrint('[QuranAudio] resumeQuranPlayer failed: $e'),
      ),
    );
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
