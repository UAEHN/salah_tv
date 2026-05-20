import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Pre-alert bell player. Kept separate from the main adhan/dua/iqama
/// AudioPlayer so the bell never interferes with cycle-state tracking.
/// Lazy on purpose: an eagerly-created idle AudioPlayer keeps ExoPlayer
/// native threads alive for hours and contributes to ANR mutex contention.
class BellPlayer {
  AudioPlayer? _player;

  Future<void> play() async {
    try {
      _player ??= AudioPlayer();
      await _player!.setVolume(0.15);
      await _player!.play(AssetSource('audio/bell.wav'));
    } catch (e) {
      debugPrint('[Audio] BellPlayer.play failed: $e');
    }
  }

  void dispose() {
    _player?.dispose();
  }
}
