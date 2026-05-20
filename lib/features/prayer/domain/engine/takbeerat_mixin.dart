import 'dart:async';

import 'prayer_cycle_base.dart';

/// Manages the Eid Takbeerat background track.
///
/// Mirrors the Quran mixin's contract intentionally: the engine owns
/// pause/resume so a user-toggled track is automatically silenced during
/// the prayer cycle (adhan → dua → iqama) and brought back afterwards.
/// All cross-mixin entry points use non-underscored names per the engine
/// convention.
mixin TakbeeratMixin on PrayerCycleBase {
  /// Tri-state toggle:
  ///  • playing     → stop and clear (user wants silence)
  ///  • stopped     → start [url]
  /// Paused-for-cycle takes precedence; toggle is a no-op in that state so
  /// the user can't override an in-progress adhan.
  void toggleTakbeerat(String url) {
    if (s.isTakbeeratPausedForCycle) return;
    if (s.isTakbeeratPlaying) {
      stopTakbeeratAndClear();
      notify();
      return;
    }
    if (url.isEmpty) return;
    s.isTakbeeratPlaying = true;
    s.takbeeratUrl = url;
    unawaited(takbeeratAudio.play(url));
    notify();
  }

  /// Hard stop used when settings change reciter or feature is disabled.
  void stopTakbeeratAndClear() {
    s.isTakbeeratPlaying = false;
    s.isTakbeeratPausedForCycle = false;
    s.takbeeratUrl = '';
    unawaited(takbeeratAudio.stop());
  }

  /// Pause when the cycle takes over. Idempotent — safe to call twice.
  void pauseTakbeeratForCycle() {
    if (!s.isTakbeeratPlaying) return;
    if (s.isTakbeeratPausedForCycle) return;
    s.isTakbeeratPausedForCycle = true;
    unawaited(takbeeratAudio.pause());
  }

  /// Resume after iqama ends. No-op when the user never started Takbeerat
  /// or when it wasn't actually paused by the cycle.
  void resumeTakbeeratAfterCycle() {
    if (!s.isTakbeeratPausedForCycle) return;
    s.isTakbeeratPausedForCycle = false;
    if (!s.isTakbeeratPlaying) return;
    unawaited(takbeeratAudio.resume());
  }
}
