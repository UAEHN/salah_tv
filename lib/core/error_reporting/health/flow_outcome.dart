import '../domain/error_severity.dart';

/// Sink for completed flow runs — the dashboard's success/failure denominator.
/// An interface so the monitor can be unit-tested without Firestore.
abstract interface class FlowRunSink {
  void record(FlowOutcome outcome, {required bool silentMode});
}

/// Terminal result of one funnel run (one prayer's adhan or iqama).
enum FlowResult {
  /// Reached the final step — the alert fully played.
  success,

  /// A step never arrived (timeout) or the engine reported an explicit
  /// failure — a silent failure the user experienced.
  failure,

  /// Intentionally not completed (silent/off mode, recovery, time-jump,
  /// city change). NOT a defect — excluded from the failure rate.
  expectedSkip,
}

/// The verdict a [FlowTracker] emits once, at the end of a run. Carries
/// everything the monitor needs to write a `flow_runs` doc and (on failure)
/// a silent-failure error record.
class FlowOutcome {
  const FlowOutcome({
    required this.flow,
    required this.prayerKey,
    required this.result,
    required this.stepsCompleted,
    this.failedStep,
    this.severity = ErrorSeverity.error,
    this.waitedMs = 0,
    this.secondsPlayed,
    this.message,
    this.reason,
    this.audioStarted = false,
  });

  final String flow;
  final String prayerKey;
  final FlowResult result;
  final List<String> stepsCompleted;
  final String? failedStep;
  final ErrorSeverity severity;
  final int waitedMs;
  final int? secondsPlayed;
  final String? message;
  final String? reason;

  /// Hard evidence that the alert's AUDIO provably started (the engine emitted
  /// `audio_start_succeeded` for this run), even if a later step failed. The
  /// classifier uses this to avoid false alarms without ever assuming: a screen
  /// step that "failed" while the sound was confirmed playing is not a defect.
  final bool audioStarted;

  FlowOutcome copyWith({FlowResult? result, String? reason}) => FlowOutcome(
    flow: flow,
    prayerKey: prayerKey,
    result: result ?? this.result,
    stepsCompleted: stepsCompleted,
    failedStep: failedStep,
    severity: severity,
    waitedMs: waitedMs,
    secondsPlayed: secondsPlayed,
    message: message,
    reason: reason ?? this.reason,
    audioStarted: audioStarted,
  );
}
