import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../domain/i_adhkar_audio_port.dart';

/// Dedicated audio player for adhkar.
/// Uses its own [AudioPlayer] instance — completely isolated from the
/// prayer cycle engine's player — so [onComplete] events never bleed
/// into adhan/dua/iqama state transitions.
class AdhkarAudioService implements IAdhkarAudioPort {
  final AudioPlayer _player = AudioPlayer();
  final StreamController<void> _onCompleteCtrl =
      StreamController<void>.broadcast();
  bool _appInitiatedStop = false;

  AdhkarAudioService() {
    // Android TV emits PlayerState.stopped instead of PlayerState.completed
    // when audio ends naturally. We listen to both events:
    // - onPlayerComplete: standard completion (most platforms)
    // - onPlayerStateChanged → stopped: natural end on Android TV
    // _appInitiatedStop guards against spurious events from explicit stop().
    _player.onPlayerComplete.listen((_) => _onCompleteCtrl.add(null));
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped && !_appInitiatedStop) {
        _onCompleteCtrl.add(null);
      }
    });
  }

  @override
  Stream<void> get onComplete => _onCompleteCtrl.stream;

  @override
  Future<void> play(String url) async {
    try {
      _appInitiatedStop = true;
      await _player.stop();
      _appInitiatedStop = false;
      await _player.play(AssetSource(url));
    } catch (e) {
      _appInitiatedStop = false;
      debugPrint('[AdhkarAudio] play failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      _appInitiatedStop = true;
      await _player.stop();
      _appInitiatedStop = false;
    } catch (_) {
      _appInitiatedStop = false;
    }
  }

  void dispose() {
    _onCompleteCtrl.close();
    _player.dispose();
  }
}
