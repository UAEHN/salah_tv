import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Smooth volume ramp helper for [QuranAudioService].
/// Cancels any in-flight ramp before starting a new one so a fade-out kicked
/// off mid fade-in lands cleanly at zero (no flicker, no orphan timers).
class QuranFadeController {
  final AudioPlayer _player;
  Completer<void>? _activeRamp;
  double _lastVolume = 0.0;

  QuranFadeController(this._player);

  Future<void> applyImmediate(double volume) async {
    _activeRamp?.complete();
    _activeRamp = null;
    _lastVolume = volume;
    try {
      await _player.setVolume(volume);
    } catch (e) {
      debugPrint('[QuranFade] setVolume failed: $e');
    }
  }

  Future<void> rampTo(
    double target, {
    Duration total = const Duration(milliseconds: 1200),
  }) async {
    _activeRamp?.complete();
    final ramp = Completer<void>();
    _activeRamp = ramp;
    const steps = 12;
    final stepDuration = total ~/ steps;
    final start = _lastVolume;
    for (var i = 1; i <= steps; i++) {
      if (ramp.isCompleted) return;
      final v = (start + (target - start) * (i / steps)).clamp(0.0, 1.0);
      _lastVolume = v;
      try {
        await _player.setVolume(v);
      } catch (_) {
        if (!ramp.isCompleted) ramp.complete();
        return;
      }
      await Future<void>.delayed(stepDuration);
    }
    if (!ramp.isCompleted) ramp.complete();
    if (identical(_activeRamp, ramp)) _activeRamp = null;
  }
}
