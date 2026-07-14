import 'dart:async';

import '../../../../core/diagnostics/diagnostic_level.dart';
import 'adhan_cycle_mixin.dart';
import 'engine_telemetry_extension.dart';
import 'prayer_diagnostics_extension.dart';

/// How long a cycle phase may stay active past its anchor before it is treated
/// as WEDGED and force-released. Comfortably above every legitimate window:
/// adhan (mosque 150s / 4-min fallback), dua (5-min fallback), iqama playback
/// (4-min fallback). The iqama-countdown anchor is [PrayerCycleState.iqamaDueAt]
/// (the fire moment), so its own delay — however long — is already accounted
/// for. Kept well under the gap to the next prayer so healing never eats into a
/// following adhan.
const Duration _kWedgeHealAfter = Duration(minutes: 10);

/// Absolute, tick-driven backstop for a WEDGED prayer cycle — the guard that
/// keeps a single stuck cycle from silently killing every following adhan.
///
/// The cycle advances through fallback [Timer]s (4–5 min) and the 1 Hz tick.
/// On a TV box those Timers are suspended while the app is backgrounded, and a
/// trigger fired unawaited can throw and leave a phase flag stuck true. Either
/// way [PrayerCycleState.isCycleActive] stays true forever, and
/// [AdhanCycleMixin.checkAdhanTrigger] returns early for EVERY later prayer — so
/// no adhan fires again until a restart. This runs every tick, detects that
/// state, reports the exact wedged phase + prayer, and force-releases the cycle.
extension CycleWedgeGuard on AdhanCycleMixin {
  void healWedgedCycleIfStuck() {
    if (!s.isCycleActive) return;
    final anchor = _wedgeAnchor();
    if (anchor == null) return;
    final over = s.now.difference(anchor);
    if (over < _kWedgeHealAfter) return;

    final phase = activeCyclePhase(s);
    // Surfaced on the dashboard via the existing cycle_stuck card…
    telCycleStuck(phase, over.inSeconds, _kWedgeHealAfter.inSeconds);
    // …and on the fast per-device trail, naming the wedged prayer + phase.
    diag(
      DiagnosticLevel.error,
      'cycle_wedge_autohealed',
      fields: {
        'wedged_phase': phase,
        'wedged_prayer': s.activeCyclePrayerKey,
        'over_sec': over.inSeconds,
      },
      forceUpload: true,
    );
    _releaseWedgedCycle();
  }

  /// The instant the active phase SHOULD have ended. For the iqama countdown
  /// that is [PrayerCycleState.iqamaDueAt] (when it should have fired); for the
  /// audible/visual phases it is when they began, with [_kWedgeHealAfter]
  /// covering the whole legitimate window plus slack.
  DateTime? _wedgeAnchor() {
    if (s.isIqamaCountdown) return s.iqamaDueAt;
    if (s.isAdhanPlaying) return s.adhanTriggerTime;
    if (s.isDuaPlaying) return s.duaTriggerTime;
    if (s.isIqamaPlaying) return s.iqamaTriggerTime;
    return null;
  }

  /// Clears every cycle flag + fallback timer so [PrayerCycleState.isCycleActive]
  /// returns false and the next prayer can fire. Mirrors
  /// [resetAdhanCycleForCityChange] but deliberately leaves [adhansToday]
  /// intact — today's already-handled prayers must not re-fire. [notify] is left
  /// to the caller ([TickMixin] notifies once at the end of the tick).
  void _releaseWedgedCycle() {
    s.adhanFallbackTimer?.cancel();
    s.duaFallbackTimer?.cancel();
    s.iqamaFallbackTimer?.cancel();
    s.isAdhanPlaying = false;
    s.isDuaPlaying = false;
    s.isIqamaCountdown = false;
    s.iqamaCountdown = Duration.zero;
    s.iqamaDueAt = null;
    s.isIqamaPlaying = false;
    s.currentAdhanPrayerKey = '';
    s.iqamaPrayerKey = '';
    s.activeCyclePrayerKey = '';
    unawaited(audio.stop());
    resumeQuranAfterAdhan();
    resumeTakbeeratAfterCycle();
  }
}
