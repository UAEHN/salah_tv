import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/domain/error_severity.dart';
import 'package:ghasaq/core/error_reporting/health/flow_definitions.dart';
import 'package:ghasaq/core/error_reporting/health/flow_outcome.dart';
import 'package:ghasaq/core/error_reporting/health/flow_outcome_classifier.dart';

FlowOutcome screenFailure({required bool audioStarted}) => FlowOutcome(
  flow: HealthFlows.adhan,
  prayerKey: 'fajr',
  result: FlowResult.failure,
  stepsCompleted: const [FlowStep.fired],
  failedStep: FlowStep.screenShown,
  severity: ErrorSeverity.error,
  audioStarted: audioStarted,
);

/// Adhan whose audio started but the completion signal never arrived within the
/// funnel window — the "did not finish" timeout.
FlowOutcome audioFinishFailure() => FlowOutcome(
  flow: HealthFlows.adhan,
  prayerKey: 'fajr',
  result: FlowResult.failure,
  stepsCompleted: const [
    FlowStep.fired,
    FlowStep.screenShown,
    FlowStep.audioStarted,
  ],
  failedStep: FlowStep.audioCompleted,
  severity: ErrorSeverity.error,
  audioStarted: true,
);

void main() {
  test('backgrounded screen failure → expected skip, not reported', () {
    final v = classifyOutcome(
      screenFailure(audioStarted: false),
      appResumed: false,
    );
    expect(v.outcome.result, FlowResult.expectedSkip);
    expect(v.outcome.reason, 'app_backgrounded');
    expect(v.silentMode, isTrue);
    expect(v.report, isFalse);
  });

  test('screen failed but audio provably started → success, not reported '
      '(proof-based, wins even when foreground)', () {
    final v = classifyOutcome(
      screenFailure(audioStarted: true),
      appResumed: true,
    );
    expect(v.outcome.result, FlowResult.success);
    expect(v.outcome.reason, 'screen_unconfirmed_audio_ok');
    expect(v.report, isFalse);
  });

  test('foreground, no screen AND no audio → real failure, reported', () {
    final v = classifyOutcome(
      screenFailure(audioStarted: false),
      appResumed: true,
    );
    expect(v.outcome.result, FlowResult.failure);
    expect(v.report, isTrue);
  });

  test('backgrounded "audio did not finish" → expected skip, not reported '
      '(user left mid-adhan / OS suspended a weak box)', () {
    final v = classifyOutcome(audioFinishFailure(), appResumed: false);
    expect(v.outcome.result, FlowResult.expectedSkip);
    expect(v.outcome.reason, 'app_backgrounded');
    expect(v.report, isFalse);
  });

  test('foreground "audio did not finish" → real failure, reported '
      '(adhan hung mid-play while the user was watching)', () {
    final v = classifyOutcome(audioFinishFailure(), appResumed: true);
    expect(v.outcome.result, FlowResult.failure);
    expect(v.report, isTrue);
  });

  test('a genuine no-sound failure (screen shown) is untouched', () {
    final o = FlowOutcome(
      flow: HealthFlows.adhan,
      prayerKey: 'fajr',
      result: FlowResult.failure,
      stepsCompleted: const [FlowStep.fired, FlowStep.screenShown],
      failedStep: FlowStep.audioStarted,
      severity: ErrorSeverity.fatal,
    );
    final v = classifyOutcome(o, appResumed: true);
    expect(v.outcome.result, FlowResult.failure);
    expect(v.outcome.severity, ErrorSeverity.fatal);
    expect(v.report, isTrue);
  });
}
