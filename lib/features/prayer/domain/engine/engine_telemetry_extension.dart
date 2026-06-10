import 'prayer_cycle_base.dart';
import 'prayer_cycle_state.dart';

/// One-line telemetry helpers used by the prayer-cycle mixins. Keeping the
/// instrumentation in an extension lets each mixin stay under the §4 150-line
/// cap while still emitting structured events for the dashboard. Every
/// helper is null-safe through `analytics?.log...` — telemetry must never
/// break the cycle (§8 CLAUDE.md).
extension EngineTelemetry on PrayerCycleBase {
  void telAdhanFallback(String prayerKey, int afterSec) => analytics
      ?.logAdhanFallbackTriggered(prayerKey: prayerKey, afterSeconds: afterSec);

  void telAdhanFail(String prayerKey) => analytics?.logAdhanAudioFailed(
    prayerKey: prayerKey,
    errorType: 'play_returned_false',
  );

  void telAdhanInaudible(
    String prayerKey,
    int volume,
    int maxVolume,
    bool muted,
  ) => analytics?.logAdhanInaudible(
    prayerKey: prayerKey,
    volume: volume,
    maxVolume: maxVolume,
    muted: muted,
  );

  void telAdhanCompletedFromState(PrayerCycleState s) {
    final d = s.adhanTriggerTime == null
        ? 0
        : s.now.difference(s.adhanTriggerTime!).inSeconds;
    analytics?.logAdhanCompleted(
      prayerKey: s.currentAdhanPrayerKey,
      durationSeconds: d,
      source: 'time',
    );
  }

  void telDuaFail(String prayerKey) => analytics?.logDuaAudioFailed(
    prayerKey: prayerKey,
    errorType: 'play_returned_false',
  );

  void telCycleReset(String reason) => analytics?.logCycleReset(reason: reason);

  void telIqamaFallback(String prayerKey, int afterSec, bool mosque) =>
      analytics?.logIqamaFallbackTriggered(
        prayerKey: prayerKey,
        afterSeconds: afterSec,
        mosqueMode: mosque,
      );

  void telIqamaFail(String prayerKey) => analytics?.logIqamaAudioFailed(
    prayerKey: prayerKey,
    errorType: 'play_returned_false',
  );

  void telIqamaCompletedFromState(PrayerCycleState s) {
    final d = s.iqamaTriggerTime == null
        ? 0
        : s.now.difference(s.iqamaTriggerTime!).inSeconds;
    analytics?.logIqamaCompleted(
      prayerKey: s.iqamaPrayerKey,
      durationSeconds: d,
      wasNatural: s.iqamaWasNaturalCompletion,
    );
  }

  // ── Phase 1C.1: cycle diagnostics ──────────────────────────────
  void telTickHeartbeat({
    required String nextPrayerKey,
    required int countdownSeconds,
    required bool isCycleActive,
    required bool hasPrayerData,
  }) => analytics?.logTickHeartbeat(
    nextPrayerKey: nextPrayerKey,
    countdownSeconds: countdownSeconds,
    isCycleActive: isCycleActive,
    hasPrayerData: hasPrayerData,
  );

  void telPrayerOverdue(
    String prayerKey,
    int overdueSec,
    String adhanMode,
    bool mosque,
  ) => analytics?.logPrayerOverdueNoTrigger(
    prayerKey: prayerKey,
    overdueSeconds: overdueSec,
    adhanMode: adhanMode,
    isMosqueMode: mosque,
  );

  void telAdhanSkipped(String prayerKey, String reason) =>
      analytics?.logAdhanSkipped(prayerKey: prayerKey, reason: reason);

  void telPrayerDataMissing(int sinceSec, String city, String country) =>
      analytics?.logPrayerDataMissing(
        sinceSeconds: sinceSec,
        city: city,
        country: country,
      );

  // ── Phase 1C.2: full cycle phase tracking ──────────────────────
  void telDuaStarted(String prayerKey, bool isSilent) =>
      analytics?.logDuaStarted(prayerKey: prayerKey, isSilent: isSilent);

  void telDuaCompletedFromState(PrayerCycleState s, String prayerKey) {
    final d = s.duaTriggerTime == null
        ? 0
        : s.now.difference(s.duaTriggerTime!).inSeconds;
    analytics?.logDuaCompleted(prayerKey: prayerKey, durationSeconds: d);
  }

  void telDuaSkipped(String prayerKey, String reason) =>
      analytics?.logDuaSkipped(prayerKey: prayerKey, reason: reason);

  void telIqamaCountdownStarted(String prayerKey, int delayMin, int remSec) =>
      analytics?.logIqamaCountdownStarted(
        prayerKey: prayerKey,
        delayMinutes: delayMin,
        remainingSeconds: remSec,
      );

  void telIqamaCountdownSkipped(String prayerKey, String reason) =>
      analytics?.logIqamaCountdownSkipped(prayerKey: prayerKey, reason: reason);

  void telQuranPausedForCycle(String trigger) =>
      analytics?.logQuranPausedForCycle(trigger: trigger);

  void telQuranResumedAfterCycle() => analytics?.logQuranResumedAfterCycle();

  void telAppLifecycle(String state, bool isCycleActive, String phase) =>
      analytics?.logAppLifecycle(
        state: state,
        isCycleActive: isCycleActive,
        activePhase: phase,
      );

  // ── Phase 1C.3: anomalies ──────────────────────────────────────
  void telCycleStuck(String phase, int stuckSec, int expectedMaxSec) =>
      analytics?.logCycleStuck(
        phase: phase,
        stuckSeconds: stuckSec,
        expectedMaxSeconds: expectedMaxSec,
      );

  void telSettingsChangeDuringCycle(String phase, String field) => analytics
      ?.logSettingsChangeDuringCycle(activePhase: phase, changedField: field);

  /// Computes a label for the active cycle phase used by app_lifecycle and
  /// cycle_stuck events. Returns 'idle' when no cycle is in progress.
  String activeCyclePhase(PrayerCycleState s) {
    if (s.isAdhanPlaying) return 'adhan';
    if (s.isDuaPlaying) return 'dua';
    if (s.isIqamaCountdown) return 'iqama_countdown';
    if (s.isIqamaPlaying) return 'iqama';
    return 'idle';
  }
}
