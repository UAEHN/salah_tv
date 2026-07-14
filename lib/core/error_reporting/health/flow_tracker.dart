import 'dart:async';

import '../domain/error_severity.dart';
import 'flow_definitions.dart';
import 'flow_outcome.dart';

/// State machine for ONE alert run (one prayer's adhan or iqama). It walks the
/// [FlowDefinition] funnel: each reached step cancels the pending timeout and
/// arms the next; a timeout, an explicit engine failure, or a silent/off
/// terminal ends the run with a single [FlowOutcome].
///
/// Tolerant of out-of-order arrivals (audio_started can land before the
/// screen's post-frame callback): reached steps accumulate in a set and the
/// frontier advances across any already-arrived steps. Purely timer-driven —
/// no wall clock, so `fake_async` fully controls it in tests.
class FlowTracker {
  FlowTracker({
    required this.flow,
    required this.prayerKey,
    required FlowDefinition definition,
    required void Function(FlowOutcome) onOutcome,
  }) : _definition = definition,
       _onOutcome = onOutcome;

  final String flow;
  final String prayerKey;
  final FlowDefinition _definition;
  final void Function(FlowOutcome) _onOutcome;

  final Set<String> _reached = {};
  int _frontier = 0;
  Timer? _timer; // cancelled on every transition + in _finish/dispose
  bool _isDone = false;

  /// Begins the run at the first (start) step and arms the first timeout.
  void start() {
    _reached.add(_definition.specs.first.step);
    _armNext();
  }

  /// A funnel step was observed (screen rendered, audio started/completed).
  void reach(String step) {
    if (_isDone) return;
    _reached.add(step);
    _advanceFrontier();
  }

  /// The engine reported an explicit failure (play returned false, fallback
  /// fired). Fails at whichever step was awaited — same grouping as a timeout.
  void failed(String reason) {
    if (_isDone) return;
    _failAtNext(reason: 'engine_failed:$reason');
  }

  /// Silent / mosque mode: a visual-only alert with no audio is the COMPLETE
  /// intended behavior (the muezzin calls live, or the user chose a silent
  /// alert), so there is no audio step to await — count it as a success, not an
  /// excluded skip, so mosque/silent cycles read as green in the dashboard.
  /// Only reached after `fired` (adhan/iqama "off" never starts a tracker), so
  /// this never green-lights a disabled alert.
  void silentVisualOnly() {
    if (_isDone) return;
    _finish(FlowResult.success, reason: 'silent_visual_only');
  }

  /// External suppression (time-jump, city change, recovery, day rollover):
  /// abandon the run without counting it as a failure.
  void abort(String reason) {
    if (_isDone) return;
    _finish(FlowResult.expectedSkip, reason: reason);
  }

  void _advanceFrontier() {
    while (_frontier + 1 < _definition.specs.length &&
        _reached.contains(_definition.specs[_frontier + 1].step)) {
      _frontier++;
    }
    if (_frontier == _definition.specs.length - 1) {
      _finish(FlowResult.success);
      return;
    }
    _armNext();
  }

  void _armNext() {
    _timer?.cancel();
    final next = _definition.specs[_frontier + 1];
    final timeout = next.timeoutFromPrev;
    if (timeout == null) return;
    _timer = Timer(timeout, () => _failAtNext());
  }

  void _failAtNext({String? reason}) {
    final missing = _definition.specs[_frontier + 1];
    // Seconds of audio that played is unknowable without a stop event; the
    // elapsed timeout since audio_started is the best lower bound.
    final secondsPlayed = missing.step == FlowStep.audioCompleted
        ? missing.timeoutFromPrev?.inSeconds
        : null;
    _finish(
      FlowResult.failure,
      failedStep: missing.step,
      severity: missing.severity,
      message: missing.message,
      waitedMs: missing.timeoutFromPrev?.inMilliseconds ?? 0,
      secondsPlayed: secondsPlayed,
      reason: reason,
    );
  }

  void _finish(
    FlowResult result, {
    String? failedStep,
    ErrorSeverity severity = ErrorSeverity.error,
    String? message,
    int waitedMs = 0,
    int? secondsPlayed,
    String? reason,
  }) {
    if (_isDone) return;
    _isDone = true;
    _timer?.cancel();
    _onOutcome(
      FlowOutcome(
        flow: flow,
        prayerKey: prayerKey,
        result: result,
        stepsCompleted: [
          for (var i = 0; i <= _frontier; i++) _definition.specs[i].step,
        ],
        failedStep: failedStep,
        severity: severity,
        waitedMs: waitedMs,
        secondsPlayed: secondsPlayed,
        message: message,
        reason: reason,
        // The audio-started signal can land before the (missing) screen frame,
        // so it lives in _reached even on a screen-step failure — carry it as
        // proof the sound played.
        audioStarted: _reached.contains(FlowStep.audioStarted),
      ),
    );
  }

  void dispose() {
    _isDone = true;
    _timer?.cancel();
    _timer = null;
  }
}
