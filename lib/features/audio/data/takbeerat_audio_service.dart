import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../prayer/domain/i_takbeerat_audio_port.dart';

/// Standalone player for the Eid Takbeerat track. Owns its own
/// [AudioPlayer] so it never collides with the adhan/dua/iqama pipeline or
/// the Quran stream. Loops the track until the engine calls [stop] or
/// pauses for the prayer cycle.
///
/// Only HTTPS URLs are accepted — anything else is rejected silently to
/// keep a malformed Remote Config row from triggering platform errors.
class TakbeeratAudioService implements ITakbeeratAudioPort {
  TakbeeratAudioService() {
    _player.setReleaseMode(ReleaseMode.loop);
    _player.onPlayerStateChanged.listen((state) {
      // Track app-visible playing state. The native player can transition
      // through paused/stopped on focus loss — keep [_isPlaying] in sync.
      if (state == PlayerState.playing) _isPlaying = true;
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        _isPlaying = false;
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String _currentUrl = '';

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> play(String url) async {
    if (!_isAllowedUrl(url)) return;
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      _currentUrl = url;
      _isPlaying = true;
      await _player.play(UrlSource(url));
    } catch (e) {
      _isPlaying = false;
      _currentUrl = '';
      debugPrint('[TakbeeratAudio] play failed: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('[TakbeeratAudio] pause failed: $e');
    }
  }

  @override
  Future<void> resume() async {
    if (_currentUrl.isEmpty) return;
    try {
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      debugPrint('[TakbeeratAudio] resume failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('[TakbeeratAudio] stop failed: $e');
    }
    _isPlaying = false;
    _currentUrl = '';
  }

  static bool _isAllowedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  void dispose() {
    _player.dispose();
  }
}
