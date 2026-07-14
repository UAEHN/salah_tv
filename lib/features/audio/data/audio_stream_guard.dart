import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/diagnostics/diagnostic_level.dart' as diag;

/// Shared `onError` handler for the app's isolated `audioplayers` streams
/// (adhkar / ayah / takbeerat / announcement).
///
/// audioplayers can surface a native MediaPlayer error ("Failed to set source",
/// MEDIA_ERROR_*) ASYNCHRONOUSLY on a player's event streams — even on an idle
/// player, after any awaited `play()` already returned. A stream listener with
/// no `onError` lets that escape to the zone as an uncaught FATAL of category
/// "Unknown" (exactly what `AudioService._onPlayerStreamError` already guards
/// for the main player). This catches it, tags it with the owning [player], and
/// records a diagnostic so the culprit is identifiable next time instead of a
/// mysterious crash.
void reportAudioStreamError(String player, Object error) {
  debugPrint('[Audio:$player] stream error: $error');
  try {
    if (GetIt.I.isRegistered<AppDiagnostics>()) {
      unawaited(
        GetIt.I<AppDiagnostics>().record(
          diag.DiagnosticLevel.warning,
          'audio_stream_error',
          fields: {
            'player': player,
            'error_type': error.runtimeType.toString(),
          },
          error: error,
          forceUpload: true,
        ),
      );
    }
  } catch (_) {
    // Diagnostics must never throw back onto the audio path.
  }
}
