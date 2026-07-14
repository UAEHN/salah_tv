import 'dart:async';

import '../domain/error_severity.dart';
import '../domain/i_error_reporting_service.dart';

/// Watchdog for the 1 Hz engine tick. The engine emits `tick_heartbeat` at
/// most once a minute; if none arrives for [_stallAfter] while the app is in
/// the foreground, the live clock/countdown has frozen — a silent failure the
/// standard error layer can't see (nothing threw).
///
/// Purely timer-driven (fake_async-friendly). Arms only after the FIRST
/// heartbeat so it never fires during a cold boot before the engine starts.
class CountdownStallDetector {
  CountdownStallDetector({
    required IErrorReportingService reporter,
    Duration stallAfter = const Duration(seconds: 150),
  }) : _reporter = reporter,
       _stallAfter = stallAfter;

  final IErrorReportingService _reporter;
  final Duration _stallAfter;

  Timer? _timer; // disposed in dispose()
  // Real wall-time since the watchdog was last (re)armed. Monotonic, so a device
  // clock jump can't inflate it; and because it keeps counting while the process
  // is frozen, on resume it reveals the TRUE freeze length — distinguishing a
  // ~150s tick hiccup from a multi-minute OS process-freeze under memory pressure
  // (the weak-box case we need to tell apart after release).
  final Stopwatch _sinceArm = Stopwatch();
  bool _isForeground = true;
  String _lastNextPrayerKey = '';
  String? _lastTickError;
  // Freeze-cause context from the last heartbeat — reported in the stall
  // evidence so a weak-box freeze says WHAT the tick carried, not just that it
  // stopped (e.g. Quran decoding starving a low-RAM CPU mid-navigation).
  bool _lastQuranPlaying = false;
  bool _lastTakbeeratPlaying = false;
  String _lastCyclePhase = '';

  /// Feed each `tick_heartbeat`. Records the context and (re)arms the watchdog.
  void onHeartbeat({
    required String nextPrayerKey,
    bool quranPlaying = false,
    bool takbeeratPlaying = false,
    String cyclePhase = '',
  }) {
    _lastNextPrayerKey = nextPrayerKey;
    _lastQuranPlaying = quranPlaying;
    _lastTakbeeratPlaying = takbeeratPlaying;
    _lastCyclePhase = cyclePhase;
    // No scheduled prayer means the live clock isn't running yet (onboarding /
    // no city, or prayer data failed to load) — there is no countdown to stall,
    // so stay disarmed until a real prayer schedule is active. A genuine freeze
    // on the home screen still carries a real next_prayer_key and is caught.
    if (nextPrayerKey.isEmpty) {
      _timer?.cancel();
      return;
    }
    _arm();
  }

  /// Feed each `tick_error` so a stall that follows an engine fault carries it.
  void onTickError(String errorHead) => _lastTickError = errorHead;

  /// Feed each `app_lifecycle`. Backgrounded apps stop ticking legitimately,
  /// so the watchdog is disarmed off-foreground (matters on mobile; TV stays
  /// resumed 24/7).
  void onLifecycle(String state) {
    _isForeground = state == 'resumed';
    if (_isForeground) {
      _arm();
    } else {
      _timer?.cancel();
    }
  }

  void _arm() {
    _timer?.cancel();
    if (!_isForeground) return;
    _sinceArm
      ..reset()
      ..start();
    _timer = Timer(_stallAfter, _onStall);
  }

  void _onStall() {
    if (!_isForeground) return;
    final frozenMs = _sinceArm.elapsed.inMilliseconds;
    _reporter.reportSilentFailure(
      name: 'countdown_stall',
      flow: 'countdown',
      prayerKey: _lastNextPrayerKey,
      failedStep: 'tick_heartbeat',
      stepsCompleted: const [],
      waitedMs: _stallAfter.inMilliseconds,
      severity: ErrorSeverity.error,
      message:
          'Countdown tick stalled: no heartbeat for '
          '${_stallAfter.inSeconds}s while in the foreground.'
          '${_lastTickError == null ? '' : ' Last tick error: $_lastTickError'}',
      evidence: {
        'quran_playing': _lastQuranPlaying,
        'takbeerat_playing': _lastTakbeeratPlaying,
        'cycle_phase': _lastCyclePhase,
        // Real freeze length: ≈150s = a tick hiccup; ≫150s = an OS process-freeze.
        'frozen_ms': frozenMs,
      },
    );
    // Re-arm so a persistent freeze reports again on the next window instead
    // of going silent after the first alert.
    _arm();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
