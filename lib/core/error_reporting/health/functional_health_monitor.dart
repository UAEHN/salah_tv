import 'dart:async';

import '../../diagnostics/adhan_journey_state.dart';
import '../bus/telemetry_bus.dart';
import '../bus/telemetry_event.dart';
import '../domain/error_severity.dart';
import '../domain/i_error_reporting_service.dart';
import 'countdown_stall_detector.dart';
import 'flow_definitions.dart';
import 'flow_outcome.dart';
import 'flow_outcome_classifier.dart';
import 'flow_tracker.dart';
import 'sequence_integrity_checker.dart';

/// The heart of Layer 3: subscribes to the [TelemetryBus] and turns the
/// engine's existing journey/diagnostic events into silent-failure detection —
/// per-prayer adhan/iqama funnels, sequence-integrity, and countdown stalls —
/// WITHOUT touching the prayer engine. Every branch is guarded; it ignores its
/// own pipeline's events (loop guard) and never throws back onto the bus.
class FunctionalHealthMonitor {
  FunctionalHealthMonitor({
    required IErrorReportingService reporter,
    required SequenceIntegrityChecker sequenceChecker,
    required CountdownStallDetector stallDetector,
    required FlowRunSink flowRunSink,
  }) : _reporter = reporter,
       _sequence = sequenceChecker,
       _stall = stallDetector,
       _flowRuns = flowRunSink;

  final IErrorReportingService _reporter;
  final SequenceIntegrityChecker _sequence;
  final CountdownStallDetector _stall;
  final FlowRunSink _flowRuns;

  StreamSubscription<TelemetryEvent>? _sub; // disposed in dispose()
  FlowTracker? _adhan;
  FlowTracker? _iqama;
  bool _appResumed = true; // tracked from app_lifecycle; gates the screen step
  // Set when the engine clears its "already fired today" set (time jump / city
  // reset). An overdue report landing within this grace is explained by that
  // reset, not a real fire failure, so it is suppressed (see _reportOverdue).
  DateTime? _lastAdhanRecordResetAt;
  static const Duration _overdueAfterResetGrace = Duration(seconds: 30);
  // When each prayer's adhan audio PROVABLY started (audio_start_succeeded).
  // Bounded to the 5 prayer keys — each new fire overwrites its own entry. An
  // overdue re-flag for a prayer whose sound recently played is proven-false, so
  // it is suppressed on hard evidence, independent of the time-jump grace above.
  final Map<String, DateTime> _adhanAudioStartedAt = {};
  // Same, for iqama — powers iqama truncation detection (parity with adhan).
  final Map<String, DateTime> _iqamaAudioStartedAt = {};
  static const Duration _audioProofWindow = Duration(hours: 6);
  // A real adhan/iqama is never this short — a "completion" sooner than this
  // means the audio died early (bad decode / output dropped), which otherwise
  // looks identical to a healthy completion in telemetry (blind spot #4).
  static const Duration _minAudioPlayback = Duration(seconds: 15);
  // Heartbeat-continuity gate: an overdue is a REAL fire failure only if the
  // engine was provably ticking THROUGH the prayer moment. We track when the
  // current uninterrupted heartbeat streak began; if it began before the prayer
  // time, the engine was alive then. A gap larger than this = the engine was
  // suspended/dead (OS killed it, box asleep) → its miss is natural, not a bug.
  DateTime? _lastHeartbeatAt;
  DateTime? _engineAliveSince;
  static const Duration _heartbeatGap = Duration(minutes: 2);

  Future<void> start(TelemetryBus bus) async {
    await _sequence.initialize();
    _sub = bus.events.listen(_onEvent);
  }

  void _onEvent(TelemetryEvent e) {
    if (e.source == TelemetrySource.errorReporting) return; // loop guard
    try {
      switch (e.name) {
        case 'adhan_journey_state':
          _routeJourney(
            HealthFlows.adhan,
            _str(e.params, 'prayer_key'),
            _str(e.params, 'adhan_final_state'),
            e.at,
            isAdhan: true,
          );
        case 'prayer_alert_journey_state':
          if (_str(e.params, 'alert_type') == HealthFlows.iqama) {
            _routeJourney(
              HealthFlows.iqama,
              _str(e.params, 'prayer_key'),
              _str(e.params, 'final_state'),
              e.at,
              isAdhan: false,
            );
          }
        case 'alert_screen_rendered':
          _trackerFor(_str(e.params, 'flow'))?.reach(FlowStep.screenShown);
        case 'prayer_overdue_no_trigger':
          _reportOverdue(e.params, e.at);
        case 'cycle_wedge_autohealed':
          // The wedge guard force-released a cycle that had been blocking every
          // later adhan. Surface it as a warning incident so the Control Room /
          // Telegram see the device that wedged — even when the heal fired in
          // time and no adhan was ultimately missed.
          _reportWedgeHealed(e.params);
        case 'adhan_trigger_threw':
          _reportTriggerThrew(HealthFlows.adhan, e.params);
        case 'iqama_trigger_threw':
          _reportTriggerThrew(HealthFlows.iqama, e.params);
        case 'tick_heartbeat':
          _onHeartbeat(e.at);
          _stall.onHeartbeat(
            nextPrayerKey: _str(e.params, 'next_prayer_key'),
            quranPlaying: _str(e.params, 'quran_playing') == 'true',
            takbeeratPlaying: _str(e.params, 'takbeerat_playing') == 'true',
            cyclePhase: _str(e.params, 'cycle_phase'),
          );
        case 'tick_error':
          _stall.onTickError(_str(e.params, 'message'));
        case 'audio_event_stream_error':
          // A native error on the SHARED adhan/iqama player while a run is open
          // means the sound that "started" actually died — link it so the run
          // is not recorded as a false success (blind spot #3). Only the main
          // player emits this; the isolated players emit 'audio_stream_error'.
          _adhan?.failed('audio_stream_error');
          _iqama?.failed('audio_stream_error');
        case 'adhan_completed':
          // The engine reports the REAL played length here; a suspiciously
          // short one means the audio died early (blind spot #4).
          final dur = int.tryParse(_str(e.params, 'duration_seconds'));
          if (dur != null) {
            _checkTruncation(
              _str(e.params, 'prayer_key'),
              dur,
              isAdhan: true,
              stoppedByUser: _str(e.params, 'stopped_by_user') == 'true',
            );
          }
        case 'iqama_completed':
          final dur = int.tryParse(_str(e.params, 'duration_seconds'));
          if (dur != null) {
            _checkTruncation(
              _str(e.params, 'prayer_key'),
              dur,
              isAdhan: false,
              stoppedByUser: _str(e.params, 'stopped_by_user') == 'true',
            );
          }
        case 'app_lifecycle':
          _appResumed = _str(e.params, 'state') == 'resumed';
          _stall.onLifecycle(_str(e.params, 'state'));
        case 'time_jump_detected':
        case 'cycle_reset':
          // Both clear the engine's adhansToday set — mark the moment so a
          // spurious overdue that follows is suppressed (see _reportOverdue).
          _lastAdhanRecordResetAt = e.at;
          _suppress(e.name);
        case 'missed_prayer_detected':
        case 'iqama_recovered':
          _suppress(e.name);
      }
    } catch (_) {
      // A monitoring fault must never disturb the app or the bus.
    }
  }

  void _routeJourney(
    String flow,
    String prayer,
    String state,
    DateTime at, {
    required bool isAdhan,
  }) {
    switch (state) {
      case AdhanJourneyState.fired:
        _startTracker(flow, prayer);
        if (isAdhan) unawaited(_sequence.onPrayerFired(prayer));
      case AdhanJourneyState.audioStarted:
        _trackerFor(flow)?.reach(FlowStep.audioStarted);
        // Proof this prayer's call to prayer actually sounded — remembered so a
        // later overdue re-flag (after a clock jump clears adhansToday) can be
        // dismissed on evidence, and so truncation can be checked at completion.
        (isAdhan ? _adhanAudioStartedAt : _iqamaAudioStartedAt)[prayer] = at;
      case AdhanJourneyState.audioCompleted:
        _trackerFor(flow)?.reach(FlowStep.audioCompleted);
      case AdhanJourneyState.failed:
        _trackerFor(flow)?.failed('journey_failed');
      case AdhanJourneyState.silentVisualOnly:
        _trackerFor(flow)?.silentVisualOnly();
    }
  }

  void _startTracker(String flow, String prayer) {
    _trackerFor(flow)?.abort('superseded');
    final tracker = FlowTracker(
      flow: flow,
      prayerKey: prayer,
      definition: flowDefinitionFor(flow),
      onOutcome: _onOutcome,
    );
    _setTracker(flow, tracker);
    tracker.start();
  }

  void _onOutcome(FlowOutcome o) {
    _setTracker(o.flow, null);
    // Evidence-based verdict (see classifyOutcome): suppress ONLY with proof —
    // a lifecycle pause, or a confirmed audio start — never on assumption.
    final v = classifyOutcome(o, appResumed: _appResumed);
    _flowRuns.record(v.outcome, silentMode: v.silentMode);
    if (!v.report) return;
    final outcome = v.outcome;
    _reporter.reportSilentFailure(
      name: '${outcome.flow}_${outcome.failedStep}',
      flow: outcome.flow,
      prayerKey: outcome.prayerKey,
      failedStep: outcome.failedStep ?? 'unknown',
      stepsCompleted: outcome.stepsCompleted,
      waitedMs: outcome.waitedMs,
      severity: outcome.severity,
      secondsPlayed: outcome.secondsPlayed,
      message: outcome.message,
      evidence: {
        'audio_started': outcome.audioStarted,
        'app_foreground': _appResumed,
      },
    );
  }

  /// Tracks the start of the current uninterrupted heartbeat streak. A gap
  /// bigger than [_heartbeatGap] (engine suspended/killed, or app just launched)
  /// resets the streak start — so [_engineAliveSince] marks the moment the
  /// engine has been provably ticking continuously since.
  void _onHeartbeat(DateTime at) {
    final last = _lastHeartbeatAt;
    if (last == null || at.difference(last) > _heartbeatGap) {
      _engineAliveSince = at;
    }
    _lastHeartbeatAt = at;
  }

  void _reportOverdue(Map<String, Object?> params, DateTime at) {
    // A time jump / city reset clears the engine's "already fired today" set
    // (adhansToday), so the overdue detector can re-flag an adhan that DID fire
    // as "never triggered" — and a real user's clock syncing (NTP after boot)
    // or a DST change reproduces it. An overdue that lands right after such a
    // reset is explained by the clock/schedule change, not a real fire failure.
    final reset = _lastAdhanRecordResetAt;
    if (reset != null && at.difference(reset) < _overdueAfterResetGrace) {
      return;
    }
    final prayer = _str(params, 'prayer_key');
    // Hard proof #2: this prayer's adhan audio provably started recently. The
    // call to prayer WAS heard; an overdue flag now is a re-flag after a reset,
    // not a real miss — suppress on evidence, whatever the jump timing.
    final startedAt = _adhanAudioStartedAt[prayer];
    final sinceAudioMs = startedAt == null
        ? null
        : at.difference(startedAt).inMilliseconds;
    if (sinceAudioMs != null &&
        sinceAudioMs < _audioProofWindow.inMilliseconds) {
      return;
    }
    final overdue = int.tryParse(_str(params, 'overdue_seconds')) ?? 0;
    // Precision gate (the decisive one): this is a REAL fire failure ONLY if the
    // engine was provably ticking THROUGH the prayer moment. If its current
    // continuous heartbeat streak began AFTER the prayer time, the engine was
    // suspended/dead/just-launched then — so no adhan is natural, not a defect.
    // This is what separates "alive and failed" (fatal) from "was asleep, woke
    // late" (natural), which the raw overdue detector cannot tell apart.
    final prayerTime = at.subtract(Duration(seconds: overdue));
    final aliveSince = _engineAliveSince;
    final engineWasAliveThrough =
        aliveSince != null && aliveSince.isBefore(prayerTime);
    if (!engineWasAliveThrough) return;
    // The engine-computed blocking cause (cycle_active_<phase> / tick_fault /
    // window_overshot / unknown) — the "exactly where it broke" that turns this
    // from "an adhan didn't fire" into an actionable Control Room incident.
    final cause = _str(params, 'cause');
    _reporter.reportSilentFailure(
      name: 'adhan_never_triggered',
      flow: HealthFlows.adhan,
      prayerKey: prayer,
      failedStep: FlowStep.fired,
      stepsCompleted: const [],
      waitedMs: overdue * 1000,
      severity: ErrorSeverity.fatal,
      message:
          'Adhan never triggered for $prayer — the engine was ticking through '
          'the prayer time yet no adhan fired (${_str(params, 'adhan_mode')} mode). '
          'Cause: ${cause.isEmpty ? 'unknown' : cause}.',
      evidence: {
        'adhan_mode': _str(params, 'adhan_mode'),
        'mosque_mode': _str(params, 'is_mosque_mode') == 'true',
        'cause': cause,
        // The decisive proof: the engine was alive through the prayer moment.
        'engine_alive': true,
        'engine_alive_since_ms': prayerTime
            .difference(aliveSince)
            .inMilliseconds,
        // Age of the last clock-reset when this fired — a small value means a
        // clock jump likely re-flagged an adhan that DID play (near-false).
        'since_time_jump_ms': ?(reset == null
            ? null
            : at.difference(reset).inMilliseconds),
        // Present only when this prayer's audio started earlier but too long ago
        // to be proof (>window) — still a triage hint.
        'since_audio_start_ms': ?sinceAudioMs,
      },
    );
  }

  /// The wedge guard force-released a cycle stuck past its expected end. Filed
  /// as WARNING (not fatal): the next prayer's adhan was rescued, but a device
  /// that wedges is worth seeing — recurring wedges point at a real bug. Named
  /// by phase so the Control Room shows exactly which phase jammed.
  void _reportWedgeHealed(Map<String, Object?> params) {
    final phase = _str(params, 'wedged_phase');
    final prayer = _str(params, 'wedged_prayer');
    final overSec = int.tryParse(_str(params, 'over_sec')) ?? 0;
    final flow = phase.startsWith('iqama')
        ? HealthFlows.iqama
        : HealthFlows.adhan;
    _reporter.reportSilentFailure(
      name: 'cycle_wedge_autohealed',
      flow: flow,
      prayerKey: prayer,
      failedStep: phase.isEmpty ? 'unknown' : phase,
      stepsCompleted: const [],
      waitedMs: overSec * 1000,
      severity: ErrorSeverity.warning,
      message:
          'A wedged "$phase" cycle (prayer $prayer) was auto-released after '
          '${overSec}s past its expected end — until the guard freed it, it was '
          'blocking every later adhan.',
      evidence: {'wedged_phase': phase, 'over_sec': overSec},
    );
  }

  /// The unawaited adhan/iqama trigger threw — the call may not have played and
  /// the cycle could be left wedged. Fatal, and named per flow so adhan and
  /// iqama trigger crashes group separately in the Control Room.
  void _reportTriggerThrew(String flow, Map<String, Object?> params) {
    final prayer = _str(params, 'trigger_prayer');
    final errorType = _str(params, 'error_type');
    _reporter.reportSilentFailure(
      name: '${flow}_trigger_threw',
      flow: flow,
      prayerKey: prayer,
      failedStep: FlowStep.fired,
      stepsCompleted: const [],
      waitedMs: 0,
      severity: ErrorSeverity.fatal,
      message:
          'The $flow trigger threw ($errorType) while firing for $prayer — the '
          'call may not have played and the cycle could be left wedged.',
      evidence: {'error_type': errorType},
    );
  }

  /// Blind spot #4: the adhan reached AUDIO_COMPLETED, but the funnel only
  /// proves the step *arrived*, not that a full adhan actually played. If the
  /// gap since AUDIO_STARTED is implausibly short, the audio died early (decode
  /// failure / output dropped) — report it even though the funnel "succeeded".
  void _checkTruncation(
    String prayer,
    int playedSeconds, {
    required bool isAdhan,
    bool stoppedByUser = false,
  }) {
    // The user dismissed the adhan/iqama takeover with the remote (select key) —
    // a short "audio" is intentional, not a decode/output failure. Never a defect.
    if (stoppedByUser) return;
    // Only real audio runs are checked — a silent/mosque cycle records no audio
    // start, so it never trips this even though it "completes" fast.
    final startedAt = isAdhan ? _adhanAudioStartedAt : _iqamaAudioStartedAt;
    if (startedAt[prayer] == null) return;
    if (playedSeconds < 0 || playedSeconds >= _minAudioPlayback.inSeconds) {
      return;
    }
    final flow = isAdhan ? HealthFlows.adhan : HealthFlows.iqama;
    _reporter.reportSilentFailure(
      name: isAdhan ? 'adhan_audio_truncated' : 'iqama_audio_truncated',
      flow: flow,
      prayerKey: prayer,
      failedStep: FlowStep.audioCompleted,
      stepsCompleted: const [
        FlowStep.fired,
        FlowStep.screenShown,
        FlowStep.audioStarted,
      ],
      waitedMs: playedSeconds * 1000,
      severity: ErrorSeverity.error,
      secondsPlayed: playedSeconds,
      message:
          'The $flow audio ended after only ${playedSeconds}s — far shorter '
          'than a real one, so this is a decode/output failure, not completion.',
      evidence: {'played_seconds': playedSeconds, 'audio_started': true},
    );
  }

  void _suppress(String reason) {
    _adhan?.abort(reason);
    _iqama?.abort(reason);
    unawaited(_sequence.reanchor());
  }

  FlowTracker? _trackerFor(String flow) => flow == HealthFlows.iqama
      ? _iqama
      : (flow == HealthFlows.adhan ? _adhan : null);

  void _setTracker(String flow, FlowTracker? tracker) {
    if (flow == HealthFlows.adhan) _adhan = tracker;
    if (flow == HealthFlows.iqama) _iqama = tracker;
  }

  static String _str(Map<String, Object?> params, String key) =>
      params[key]?.toString() ?? '';

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _adhan?.dispose();
    _iqama?.dispose();
    _stall.dispose();
  }
}
