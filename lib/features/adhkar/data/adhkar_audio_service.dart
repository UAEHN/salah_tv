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

  // Mirror of AudioService._isPlaying: prevents the double-completion cascade
  // that occurs on Android TV, where both onPlayerComplete AND
  // onPlayerStateChanged(stopped) fire when audio ends naturally.
  // Without this guard, advance() is called twice per dhikr, which creates
  // two concurrent play() calls that race on the platform channel and generate
  // more spurious stopped events — a cascade that overwhelms the channel and
  // causes an ANR after ~2 hours of operation.
  bool _isPlaying = false;

  AdhkarAudioService() {
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _onCompleteCtrl.add(null);
    });
    // Android TV emits PlayerState.stopped instead of PlayerState.completed
    // when audio ends naturally. The _isPlaying guard ensures only ONE
    // completion event reaches the cubit regardless of which event fires first.
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped && _isPlaying && !_appInitiatedStop) {
        _isPlaying = false;
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
      _isPlaying = true;
      await _player.play(AssetSource(url));
    } catch (e) {
      _appInitiatedStop = false;
      _isPlaying = false;
      debugPrint('[AdhkarAudio] play failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      _appInitiatedStop = true;
      await _player.stop();
      _isPlaying = false;
      _appInitiatedStop = false;
    } catch (e) {
      debugPrint('[AdhkarAudio] stop failed: $e');
      _appInitiatedStop = false;
    }
  }

  void dispose() {
    _onCompleteCtrl.close();
    _player.dispose();
  }
}
