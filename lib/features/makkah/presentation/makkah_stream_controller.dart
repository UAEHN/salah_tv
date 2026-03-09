import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../domain/i_makkah_stream_repository.dart';

enum MakkahStreamState { idle, loading, playing, error }

class MakkahStreamController {
  static const kMakkahVideoId = 'Cm1v4bteXbI';

  /// Global flag — HeroCard listens to this to decide whether to strip its border.
  static final ValueNotifier<bool> isStreamPlaying = ValueNotifier(false);

  final IMakkahStreamRepository _repo;

  MakkahStreamController(this._repo);

  final ValueNotifier<MakkahStreamState> state = ValueNotifier(
    MakkahStreamState.idle,
  );
  final ValueNotifier<bool> isMuted = ValueNotifier(true);

  VideoPlayerController? _controller;
  VideoPlayerController? get controller => _controller;

  Timer? _retryTimer;
  bool _isDisposed = false;

  Future<void> initialize() async {
    if (_isDisposed) return;
    _cancelRetry();
    state.value = MakkahStreamState.loading;

    try {
      final url = await _repo.extractStreamUrl(kMakkahVideoId);
      if (url == null) {
        debugPrint('[MakkahStream] extraction returned null — retrying');
        state.value = MakkahStreamState.error;
        _scheduleRetry();
        return;
      }
      if (_isDisposed) return;

      final vc = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      // Live streams may never fire the "prepared" event — enforce a timeout.
      await vc.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('ExoPlayer init timed out'),
      );

      if (_isDisposed) {
        await vc.dispose();
        return;
      }

      debugPrint(
        '[MakkahStream] init OK — size: ${vc.value.size}, isPlaying: ${vc.value.isPlaying}',
      );

      // Catch silent ExoPlayer errors that surface after initialization.
      vc.addListener(() {
        if (_isDisposed || _controller != vc) return;
        if (vc.value.hasError) {
          debugPrint(
            '[MakkahStream] ExoPlayer error: ${vc.value.errorDescription}',
          );
          final dead = _controller;
          _controller = null;
          isStreamPlaying.value = false;
          state.value = MakkahStreamState.error;
          _scheduleRetry();
          dead?.dispose();
        }
      });

      await vc.setLooping(true);
      await vc.setVolume(isMuted.value ? 0.0 : 1.0);
      await vc.play();
      _controller = vc;
      state.value = MakkahStreamState.playing;
      isStreamPlaying.value = true;
    } catch (e) {
      debugPrint('[MakkahStream] video_player init failed: $e');
      state.value = MakkahStreamState.error;
      _scheduleRetry();
    }
  }

  Future<void> pause() async {
    _cancelRetry();
    final vc = _controller;
    _controller = null;
    state.value = MakkahStreamState.idle;
    isStreamPlaying.value = false;
    await vc?.dispose();
  }

  Future<void> resume() => initialize();

  void toggleMute() {
    isMuted.value = !isMuted.value;
    _controller?.setVolume(isMuted.value ? 0.0 : 1.0);
  }

  void setMuted(bool value) {
    if (isMuted.value == value) return;
    isMuted.value = value;
    _controller?.setVolume(value ? 0.0 : 1.0);
  }

  void _scheduleRetry() {
    _cancelRetry();
    _retryTimer = Timer(const Duration(seconds: 15), () {
      _retryTimer = null;
      if (!_isDisposed) initialize();
    });
  }

  void _cancelRetry() => _retryTimer?.cancel();

  Future<void> dispose() async {
    _isDisposed = true;
    _cancelRetry();
    final vc = _controller;
    _controller = null;
    isStreamPlaying.value = false;
    // Don't dispose state/isMuted — external ValueListenableBuilders may
    // still reference them during the same frame. GC'd with this instance.
    state.value = MakkahStreamState.idle;
    _repo.dispose();
    await vc?.dispose();
  }
}
