import '../domain/i_analytics_service.dart';
import 'firebase_analytics_base.dart';

/// Prayer cycle health telemetry (Phase 1B).
mixin PrayerHealthEventsMixin on FirebaseAnalyticsBase
    implements IAnalyticsService {
  @override
  void logAdhanAudioFailed({
    required String prayerKey,
    required String errorType,
  }) => logEventInternal('adhan_audio_failed', {
    'prayer_key': prayerKey,
    'error_type': errorType,
  });

  @override
  void logDuaAudioFailed({
    required String prayerKey,
    required String errorType,
  }) => logEventInternal('dua_audio_failed', {
    'prayer_key': prayerKey,
    'error_type': errorType,
  });

  @override
  void logIqamaAudioFailed({
    required String prayerKey,
    required String errorType,
  }) => logEventInternal('iqama_audio_failed', {
    'prayer_key': prayerKey,
    'error_type': errorType,
  });

  @override
  void logAdhanFallbackTriggered({
    required String prayerKey,
    required int afterSeconds,
  }) => logEventInternal('adhan_fallback_triggered', {
    'prayer_key': prayerKey,
    'after_seconds': afterSeconds,
  });

  @override
  void logIqamaFallbackTriggered({
    required String prayerKey,
    required int afterSeconds,
    required bool mosqueMode,
  }) => logEventInternal('iqama_fallback_triggered', {
    'prayer_key': prayerKey,
    'after_seconds': afterSeconds,
    'mosque_mode': mosqueMode.toString(),
  });

  @override
  void logAdhanCompleted({
    required String prayerKey,
    required int durationSeconds,
    required String source,
  }) => logEventInternal('adhan_completed', {
    'prayer_key': prayerKey,
    'duration_seconds': durationSeconds,
    'source': source,
  });

  @override
  void logIqamaCompleted({
    required String prayerKey,
    required int durationSeconds,
    required bool wasNatural,
  }) => logEventInternal('iqama_completed', {
    'prayer_key': prayerKey,
    'duration_seconds': durationSeconds,
    'was_natural': wasNatural.toString(),
  });

  @override
  void logCycleReset({required String reason}) =>
      logEventInternal('cycle_reset', {'reason': reason});

  @override
  void logMissedPrayerDetected({
    required String prayerKey,
    required int deltaMinutes,
  }) => logEventInternal('missed_prayer_detected', {
    'prayer_key': prayerKey,
    'delta_minutes': deltaMinutes,
  });

  @override
  void logIqamaRecovered({
    required String prayerKey,
    required int remainingSeconds,
  }) => logEventInternal('iqama_recovered', {
    'prayer_key': prayerKey,
    'remaining_seconds': remainingSeconds,
  });

  @override
  void logTimeJumpDetected({required int driftSeconds}) =>
      logEventInternal('time_jump_detected', {'drift_seconds': driftSeconds});
}
