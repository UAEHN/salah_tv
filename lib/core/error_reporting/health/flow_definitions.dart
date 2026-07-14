import '../domain/error_severity.dart';

/// Flow identifiers (also the `flow` field on error_events + flow_runs).
class HealthFlows {
  const HealthFlows._();
  static const String adhan = 'adhan';
  static const String iqama = 'iqama';
}

/// Funnel step names. Wire values — they appear as `failed_step` on incidents
/// and drive the dashboard's per-step drill-down, so keep them stable.
class FlowStep {
  const FlowStep._();
  static const String fired = 'fired';
  static const String screenShown = 'alert_screen_shown';
  static const String audioStarted = 'audio_started';
  static const String audioCompleted = 'audio_completed';
}

/// One node in a flow's ordered funnel. [timeoutFromPrev] is how long the
/// step is allowed to arrive after the previous one (null for the start
/// step). On timeout, a silent failure is logged with [severity]/[message].
class FlowStepSpec {
  const FlowStepSpec({
    required this.step,
    this.timeoutFromPrev,
    this.severity = ErrorSeverity.error,
    this.message = '',
  });

  final String step;
  final Duration? timeoutFromPrev;
  final ErrorSeverity severity;
  final String message;
}

/// An ordered funnel for one alert type.
class FlowDefinition {
  const FlowDefinition(this.specs);
  final List<FlowStepSpec> specs;
}

/// Adhan funnel: fired → screen (10s) → audio (8s) → completed (5.5min).
/// "Screen shown but no sound" is the single most user-visible failure for
/// this app (build spec) → Fatal.
const FlowDefinition kAdhanFlow = FlowDefinition([
  FlowStepSpec(step: FlowStep.fired),
  FlowStepSpec(
    step: FlowStep.screenShown,
    timeoutFromPrev: Duration(seconds: 10),
    severity: ErrorSeverity.error,
    message: 'Adhan screen did not appear after the countdown reached zero.',
  ),
  FlowStepSpec(
    step: FlowStep.audioStarted,
    timeoutFromPrev: Duration(seconds: 8),
    severity: ErrorSeverity.fatal,
    message: 'Adhan screen appeared but no sound started.',
  ),
  FlowStepSpec(
    step: FlowStep.audioCompleted,
    timeoutFromPrev: Duration(minutes: 5, seconds: 30),
    severity: ErrorSeverity.error,
    message: 'Adhan audio started but did not finish.',
  ),
]);

/// Iqama funnel: same shape, no-sound is Error (less severe than adhan).
const FlowDefinition kIqamaFlow = FlowDefinition([
  FlowStepSpec(step: FlowStep.fired),
  FlowStepSpec(
    step: FlowStep.screenShown,
    timeoutFromPrev: Duration(seconds: 10),
    severity: ErrorSeverity.error,
    message: 'Iqama screen did not appear.',
  ),
  FlowStepSpec(
    step: FlowStep.audioStarted,
    timeoutFromPrev: Duration(seconds: 8),
    severity: ErrorSeverity.error,
    message: 'Iqama screen appeared but no sound started.',
  ),
  FlowStepSpec(
    step: FlowStep.audioCompleted,
    timeoutFromPrev: Duration(minutes: 5),
    severity: ErrorSeverity.error,
    message: 'Iqama audio started but did not finish.',
  ),
]);

FlowDefinition flowDefinitionFor(String flow) =>
    flow == HealthFlows.iqama ? kIqamaFlow : kAdhanFlow;
