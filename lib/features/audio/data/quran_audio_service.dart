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
  // Fires when a surah fails to load/play (CDN hung, network down, timeout) so
  // the engine can surface a non-silent message to the user (TV §8 — no silent
  // failures).
  final StreamController<void> _errorCtrl = StreamController<void>.broadcast();
  // Emits true while a surah is loading/buffering (slow network) so the UI can
  // show a loading indicator instead of an apparent silent stall.
  final StreamController<bool> _loadingCtrl =
      StreamController<bool>.broadcast();
  bool _lastLoading = false;
  String _quranServerUrl = '';
  int _quranSurahIndex = 0; // 0-based (surah 1 = index 0)
  DateTime? _quranPausedAt; // Issue 7: tracks when Quran was paused
  NextSurahResolver? _nextSurahResolver;
  late final QuranFadeController _fade = QuranFadeController(_quranPlayer);
  // Guards completion against re-entrant double-fire on Android TV.
  bool _isTransitioning = false;
  // Network load guard: a hung CDN must never stall the prayer cycle.
  static const _loadTimeout = Duration(seconds: 20);
  // Auto-retry a failed load so a transient outage recovers on its own —
  // the user keeps Quran "on" and it resumes when the network returns, instead
  // of dying silently until a manual toggle. Cancelled on any explicit action.
  Timer? _retryTimer; // cancelled in pause/stop/playSurah/restart/dispose
  static const _retryDelay = Duration(seconds: 8);
  // Safety net for a mid-stream stall that never surfaces as an explicit error
  // (player sits in buffering forever after the network drops). Longer than
  // [_loadTimeout] so a normal initial load is handled by that path first.
  Timer? _bufferWatchdog; // cancelled in stop/pause/dispose + on ready
  static const _bufferStallTimeout = Duration(seconds: 25);

  int get quranSurahIndex => _quranSurahIndex;
  int? get currentSurahNumber =>
      _quranServerUrl.isEmpty ? null : _quranSurahIndex + 1;
  Stream<int> get onSurahCompleted => _surahCompletedCtrl.stream;
  Stream<void> get onError => _errorCtrl.stream;
  Stream<bool> get onLoading => _loadingCtrl.stream;
  void setNextSurahResolver(NextSurahResolver? resolver) =>
      _nextSurahResolver = resolver;

  QuranAudioService() {
    // just_audio signals end-of-track via ProcessingState.completed (the
    // equivalent of audioplayers' onPlayerComplete).
    _quranPlayer.processingStateStream.listen((state) {
      final isBuffering =
          _quranServerUrl.isNotEmpty &&
          (state == ProcessingState.loading ||
              state == ProcessingState.buffering);
      _emitLoading(isBuffering);
      _updateBufferWatchdog(isBuffering);
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
    // Mid-stream failures (Wi-Fi dropped WHILE a surah is playing) surface as an
    // error on the playback event stream, NOT through _playCurrentSurah's
    // try/catch (which only guards the initial load). Route them to the same
    // error + auto-retry path so playback recovers when the network returns.
    _quranPlayer.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace _) {
        debugPrint('[QuranAudio] playback stream error: $e');
        if (_quranServerUrl.isEmpty) return; // not meant to be playing
        _emitLoading(false);
        _emitError();
        _scheduleRetry();
      },
    );
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
      _retryTimer?.cancel(); // loaded OK — drop any pending recovery retry
      // play() resolves only when playback ends, so it must not be awaited.
      unawaited(_quranPlayer.play());
      unawaited(_fade.rampTo(1.0));
    } catch (e) {
      debugPrint('[QuranAudio] _playCurrentSurah failed: $e');
      _emitLoading(false);
      _emitError();
      _scheduleRetry(); // keep trying while the user still wants Quran on
    }
  }

  /// Re-attempts the current surah after [_retryDelay] so a transient network
  /// outage recovers without a manual toggle. A no-op once Quran is stopped
  /// (server URL cleared). Superseded/cancelled by any explicit play/pause/stop.
  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      if (_quranServerUrl.isEmpty) return; // stopped/paused meanwhile
      _emitLoading(true); // show the spinner while the retry loads
      _playCurrentSurah();
    });
  }

  /// Arms a single watchdog while buffering, disarms it once playback is ready.
  /// If buffering outlasts [_bufferStallTimeout] the stream has silently stalled
  /// (network dropped mid-play without an error), so surface it and retry.
  void _updateBufferWatchdog(bool buffering) {
    if (buffering) {
      _bufferWatchdog ??= Timer(_bufferStallTimeout, () {
        _bufferWatchdog = null;
        if (_quranServerUrl.isEmpty) return;
        debugPrint('[QuranAudio] buffering stalled — forcing retry');
        _emitLoading(false);
        _emitError();
        _scheduleRetry();
      });
    } else {
      _bufferWatchdog?.cancel();
      _bufferWatchdog = null;
    }
  }

  void _emitError() {
    if (!_errorCtrl.isClosed) _errorCtrl.add(null);
  }

  void _emitLoading(bool loading) {
    if (loading == _lastLoading) return; // dedup repeated buffering events
    _lastLoading = loading;
    if (!_loadingCtrl.isClosed) _loadingCtrl.add(loading);
  }

  Future<void> playQuranFromServer(String serverUrl) => playSurah(serverUrl, 1);

  Future<void> playSurah(String serverUrl, int surahNumber) async {
    if (!_isAllowedQuranUrl(serverUrl)) return;
    if (surahNumber < 1 || surahNumber > 114) return;
    _retryTimer?.cancel(); // explicit play supersedes any pending retry
    _quranServerUrl = serverUrl;
    _quranSurahIndex = surahNumber - 1;
    _isTransitioning = false;
    _quranPausedAt = null;
    await _quranPlayer.stop();
    await _playCurrentSurah();
  }

  Future<void> pauseQuranPlayer() async {
    _retryTimer?.cancel(); // user paused — stop retrying until they resume
    _bufferWatchdog?.cancel();
    _bufferWatchdog = null;
    _quranPausedAt = DateTime.now(); // Issue 7
    try {
      await _quranPlayer.pause();
    } catch (e) {
      debugPrint('[QuranAudio] pauseQuranPlayer failed: $e');
    }
  }

  /// Issue 7: if paused >60s the HTTP stream timed out — restart current surah.
  /// Also restart when the reciter changed while paused: the loaded stream is
  /// the OLD reciter, so resuming it would replay the previous voice even
  /// though [serverUrl] (and the UI name) point at the new one. Restarting
  /// reloads the current surah from the new reciter's CDN folder.
  Future<void> resumeOrRestartQuranPlayer(String serverUrl) async {
    final pausedAt = _quranPausedAt;
    _quranPausedAt = null;
    final reciterChanged =
        _isAllowedQuranUrl(serverUrl) && serverUrl != _quranServerUrl;
    final longPause =
        pausedAt != null && DateTime.now().difference(pausedAt).inSeconds > 60;
    if (reciterChanged || longPause) return restartQuranCurrentSurah(serverUrl);
    // play() resolves only at end-of-track, so start it without awaiting and
    // route any failure to the log instead of an unhandled future error.
    unawaited(
      _quranPlayer.play().catchError(
        (Object e) => debugPrint('[QuranAudio] resume after pause failed: $e'),
      ),
    );
  }

  Future<void> restartQuranCurrentSurah(String serverUrl) async {
    _retryTimer?.cancel(); // explicit restart supersedes any pending retry
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
      _retryTimer?.cancel(); // user stopped — abandon any pending retry
      _bufferWatchdog?.cancel();
      _bufferWatchdog = null;
      _isTransitioning = false;
      _quranServerUrl = '';
      _quranSurahIndex = 0;
      await _fade.rampTo(0.0, total: const Duration(milliseconds: 700));
      // A fast re-open during the 700ms fade re-claims the player by setting a
      // new server URL (playSurah does so synchronously before any await). Don't
      // stop it out from under the fresh playback — otherwise a quick
      // close-then-open leaves the player silently stopped.
      if (_quranServerUrl.isNotEmpty) return;
      await _quranPlayer.stop();
    } catch (e) {
      debugPrint('[QuranAudio] stopQuranPlayer failed: $e');
    }
  }

  void dispose() {
    _retryTimer?.cancel();
    _bufferWatchdog?.cancel();
    _surahCompletedCtrl.close();
    _errorCtrl.close();
    _loadingCtrl.close();
    _quranPlayer.dispose();
  }
}
