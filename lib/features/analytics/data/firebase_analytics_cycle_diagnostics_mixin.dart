import '../domain/i_analytics_service.dart';
import 'firebase_analytics_base.dart';

/// Cycle-engine diagnostics (Phase 1C). Lets the dashboard answer
/// "did the adhan fire, and if not, why?" — heartbeat, overdue,
/// skipped, missing data, phase tracking, and anomalies.
mixin CycleDiagnosticsMixin on FirebaseAnalyticsBase
    implements IAnalyticsService {
  // ── 1C.1: "did the adhan even try to fire?" ─────────────────────

  @override
  void logTickHeartbeat({
    required String nextPrayerKey,
    required int countdownSeconds,
    required bool isCycleActive,
    required bool hasPrayerData,
  }) => logEventInternal('tick_heartbeat', {
    'next_prayer_key': nextPrayerKey,
    'countdown_seconds': countdownSeconds,
    'is_cycle_active': isCycleActive.toString(),
    'has_prayer_data': hasPrayerData.toString(),
  });

  @override
  void logPrayerOverdueNoTrigger({
    required String prayerKey,
    required int overdueSeconds,
    required String adhanMode,
    required bool isMosqueMode,
  }) => logEventInternal('prayer_overdue_no_trigger', {
    'prayer_key': prayerKey,
    'overdue_seconds': overdueSeconds,
    'adhan_mode': adhanMode,
    'is_mosque_mode': isMosqueMode.toString(),
  });

  @override
  void logAdhanSkipped({required String prayerKey, required String reason}) =>
      logEventInternal('adhan_skipped', {
        'prayer_key': prayerKey,
        'reason': reason,
      });

  @override
  void logAdhanInaudible({
    required String prayerKey,
    required int volume,
    required int maxVolume,
    required bool muted,
  }) => logEventInternal('adhan_inaudible', {
    'prayer_key': prayerKey,
    'volume': volume,
    'max_volume': maxVolume,
    'muted': muted.toString(),
  });

  @override
  void logPrayerDataMissing({
    required int sinceSeconds,
    required String city,
    required String country,
  }) => logEventInternal('prayer_data_missing', {
    'since_seconds': sinceSeconds,
    'city': city,
    'country': country,
  });

  // ── 1C.2: full cycle phase tracking ─────────────────────────────

  @override
  void logDuaStarted({required String prayerKey, required bool isSilent}) =>
      logEventInternal('dua_started', {
        'prayer_key': prayerKey,
        'is_silent': isSilent.toString(),
      });

  @override
  void logDuaCompleted({
    required String prayerKey,
    required int durationSeconds,
  }) => logEventInternal('dua_completed', {
    'prayer_key': prayerKey,
    'duration_seconds': durationSeconds,
  });

  @override
  void logDuaSkipped({required String prayerKey, required String reason}) =>
      logEventInternal('dua_skipped', {
        'prayer_key': prayerKey,
        'reason': reason,
      });

  @override
  void logIqamaCountdownStarted({
    required String prayerKey,
    required int delayMinutes,
    required int remainingSeconds,
  }) => logEventInternal('iqama_countdown_started', {
    'prayer_key': prayerKey,
    'delay_minutes': delayMinutes,
    'remaining_seconds': remainingSeconds,
  });

  @override
  void logIqamaCountdownSkipped({
    required String prayerKey,
    required String reason,
  }) => logEventInternal('iqama_countdown_skipped', {
    'prayer_key': prayerKey,
    'reason': reason,
  });

  @override
  void logQuranPausedForCycle({required String trigger}) =>
      logEventInternal('quran_paused_for_cycle', {'trigger': trigger});

  @override
  void logQuranResumedAfterCycle() =>
      logEventInternal('quran_resumed_after_cycle');

  @override
  void logAppLifecycle({
    required String state,
    required bool isCycleActive,
    required String activePhase,
  }) => logEventInternal('app_lifecycle', {
    'state': state,
    'is_cycle_active': isCycleActive.toString(),
    'active_phase': activePhase,
  });

  // ── 1C.3: anomalies ─────────────────────────────────────────────

  @override
  void logCycleStuck({
    required String phase,
    required int stuckSeconds,
    required int expectedMaxSeconds,
  }) => logEventInternal('cycle_stuck', {
    'phase': phase,
    'stuck_seconds': stuckSeconds,
    'expected_max_seconds': expectedMaxSeconds,
  });

  @override
  void logSettingsChangeDuringCycle({
    required String activePhase,
    required String changedField,
  }) => logEventInternal('settings_change_during_cycle', {
    'active_phase': activePhase,
    'changed_field': changedField,
  });
}
