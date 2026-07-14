import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error_reporting/domain/error_severity.dart';
import 'package:ghasaq/core/error_reporting/health/flow_definitions.dart';
import 'package:ghasaq/core/error_reporting/health/flow_outcome.dart';
import 'package:ghasaq/core/error_reporting/health/flow_tracker.dart';

void main() {
  FlowTracker build(
    void Function(FlowOutcome) onOutcome, {
    String flow = HealthFlows.adhan,
  }) => FlowTracker(
    flow: flow,
    prayerKey: 'dhuhr',
    definition: flowDefinitionFor(flow),
    onOutcome: onOutcome,
  );

  test('happy path: all steps arrive → success', () {
    fakeAsync((async) {
      FlowOutcome? outcome;
      final tracker = build((o) => outcome = o)..start();
      tracker.reach(FlowStep.screenShown);
      async.elapse(const Duration(seconds: 2));
      tracker.reach(FlowStep.audioStarted);
      async.elapse(const Duration(seconds: 3));
      tracker.reach(FlowStep.audioCompleted);
      expect(outcome?.result, FlowResult.success);
      expect(outcome?.stepsCompleted, [
        FlowStep.fired,
        FlowStep.screenShown,
        FlowStep.audioStarted,
        FlowStep.audioCompleted,
      ]);
      async.flushTimers();
    });
  });

  test('screen never appears → failure(alert_screen_shown, error)', () {
    fakeAsync((async) {
      FlowOutcome? outcome;
      build((o) => outcome = o).start();
      async.elapse(const Duration(seconds: 11));
      expect(outcome?.result, FlowResult.failure);
      expect(outcome?.failedStep, FlowStep.screenShown);
      expect(outcome?.severity, ErrorSeverity.error);
      expect(outcome?.stepsCompleted, [FlowStep.fired]);
    });
  });

  test('adhan screen shown but no sound → Fatal', () {
    fakeAsync((async) {
      FlowOutcome? outcome;
      final tracker = build((o) => outcome = o)..start();
      tracker.reach(FlowStep.screenShown);
      async.elapse(const Duration(seconds: 9));
      expect(outcome?.result, FlowResult.failure);
      expect(outcome?.failedStep, FlowStep.audioStarted);
      expect(outcome?.severity, ErrorSeverity.fatal);
    });
  });

  test('audio cut off → failure(audio_completed) with secondsPlayed', () {
    fakeAsync((async) {
      FlowOutcome? outcome;
      final tracker = build((o) => outcome = o)..start();
      tracker.reach(FlowStep.screenShown);
      tracker.reach(FlowStep.audioStarted);
      async.elapse(const Duration(minutes: 6));
      expect(outcome?.result, FlowResult.failure);
      expect(outcome?.failedStep, FlowStep.audioCompleted);
      expect(outcome?.secondsPlayed, 330);
    });
  });

  test('out-of-order: audio_started before screen still succeeds', () {
    fakeAsync((async) {
      FlowOutcome? outcome;
      final tracker = build((o) => outcome = o)..start();
      tracker.reach(FlowStep.audioStarted); // arrives first
      tracker.reach(FlowStep.screenShown); // frontier jumps across both
      tracker.reach(FlowStep.audioCompleted);
      expect(outcome?.result, FlowResult.success);
      async.flushTimers();
    });
  });

  test('silentVisualOnly → success (mosque/silent visual-only is the full '
      'intended flow — no audio step to await)', () {
    fakeAsync((async) {
      FlowOutcome? outcome;
      final tracker = build((o) => outcome = o)..start();
      tracker.reach(FlowStep.screenShown);
      tracker.silentVisualOnly();
      expect(outcome?.result, FlowResult.success);
      expect(outcome?.reason, 'silent_visual_only');
      async.flushTimers();
    });
  });

  test('screen fails but audio already started → outcome carries audioStarted '
      'evidence', () {
    fakeAsync((async) {
      FlowOutcome? outcome;
      final tracker = build((o) => outcome = o)..start();
      tracker.reach(FlowStep.audioStarted); // sound started before any frame
      async.elapse(const Duration(seconds: 11)); // screen never arrives
      expect(outcome?.result, FlowResult.failure);
      expect(outcome?.failedStep, FlowStep.screenShown);
      expect(outcome?.audioStarted, isTrue);
    });
  });

  test('explicit engine failure → failure at the awaited step', () {
    fakeAsync((async) {
      FlowOutcome? outcome;
      final tracker = build((o) => outcome = o)..start();
      tracker.reach(FlowStep.screenShown);
      tracker.failed('play_returned_false');
      expect(outcome?.result, FlowResult.failure);
      expect(outcome?.failedStep, FlowStep.audioStarted);
      async.flushTimers();
    });
  });

  test('abort → expectedSkip, cancels timers (no late outcome)', () {
    fakeAsync((async) {
      var outcomes = 0;
      final tracker = build((_) => outcomes++)..start();
      tracker.abort('time_jump');
      async.elapse(const Duration(minutes: 10));
      expect(outcomes, 1); // only the abort outcome, no timeout after
    });
  });

  test('iqama no-sound is Error, not Fatal', () {
    fakeAsync((async) {
      FlowOutcome? outcome;
      final tracker = build((o) => outcome = o, flow: HealthFlows.iqama)
        ..start();
      tracker.reach(FlowStep.screenShown);
      async.elapse(const Duration(seconds: 9));
      expect(outcome?.failedStep, FlowStep.audioStarted);
      expect(outcome?.severity, ErrorSeverity.error);
    });
  });
}
