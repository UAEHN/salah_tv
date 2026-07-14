import 'flow_definitions.dart';
import 'flow_outcome.dart';

/// The final decision about a completed flow run — the (possibly reclassified)
/// outcome to record, whether it counts as a silent mode run, and whether it
/// warrants a reported incident.
class FlowVerdict {
  const FlowVerdict(
    this.outcome, {
    required this.silentMode,
    required this.report,
  });

  final FlowOutcome outcome;
  final bool silentMode;
  final bool report;
}

/// Decides what a finished flow run MEANS, using hard evidence only — never an
/// assumption. This is the guard against false alarms on other people's devices:
/// we downgrade a signal only when the data proves the core behavior happened.
///
/// Precedence for a screen-step failure:
///   1. App backgrounded (`app_lifecycle: paused`) → Android can't paint a
///      background window, so a "screen not shown" there is expected, not a
///      defect. Proof: the lifecycle event. → expected skip, no incident.
///      The SAME lifecycle proof covers an unfinished-audio timeout: a user who
///      leaves mid-adhan (or an OS that suspends a weak box) legitimately never
///      lets the call finish — the sound was fine, the app simply left, so a
///      backgrounded `audio_completed` timeout is expected too, not a defect.
///   2. The adhan/iqama SOUND provably started (`audio_start_succeeded` landed
///      before the missing screen frame). The call to prayer was heard — the
///      core function worked; only the on-screen takeover is unconfirmed (a TV
///      switched off or to another HDMI input keeps the app "resumed" yet paints
///      nothing, which we cannot disprove and need not). → count the sound as
///      success, no false alarm. Proof: the audio-started signal.
///   3. Neither the screen NOR the sound happened while the app was foreground →
///      a genuine silent failure the user experienced. → report it. An
///      `audio_completed` timeout while STILL foreground is likewise real — the
///      adhan hung mid-play with the user watching — so it falls through here.
FlowVerdict classifyOutcome(FlowOutcome o, {required bool appResumed}) {
  final isScreenFailure =
      o.result == FlowResult.failure && o.failedStep == FlowStep.screenShown;
  // A timeout waiting for the adhan/iqama audio to FINISH (audio provably
  // started, completion never observed). Distinct from a no-sound failure.
  final isAudioFinishFailure =
      o.result == FlowResult.failure &&
      o.failedStep == FlowStep.audioCompleted;

  if ((isScreenFailure || isAudioFinishFailure) && !appResumed) {
    return FlowVerdict(
      o.copyWith(result: FlowResult.expectedSkip, reason: 'app_backgrounded'),
      silentMode: true,
      report: false,
    );
  }

  if (isScreenFailure && o.audioStarted) {
    return FlowVerdict(
      o.copyWith(
        result: FlowResult.success,
        reason: 'screen_unconfirmed_audio_ok',
      ),
      silentMode: false,
      report: false,
    );
  }

  return FlowVerdict(
    o,
    silentMode: o.reason == 'silent_visual_only',
    report: o.result == FlowResult.failure,
  );
}
