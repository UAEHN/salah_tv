import '../domain/i_analytics_service.dart';
import 'firebase_analytics_base.dart';

/// Data, network, and Quran playback telemetry (Phase 1B).
mixin DataEventsMixin on FirebaseAnalyticsBase implements IAnalyticsService {
  @override
  void logPrayerSourceFallback({
    required String city,
    required String reason,
  }) => logEventInternal('prayer_source_fallback', {
    'city': city,
    'reason': reason,
  });

  @override
  void logNetworkFailure({
    required String repo,
    required int statusCode,
    required String errorType,
  }) => logEventInternal('network_failure', {
    'repo': repo,
    'status_code': statusCode,
    'error_type': errorType,
  });

  @override
  void logDbOperationSlow({
    required String table,
    required String op,
    required int durationMs,
  }) => logEventInternal('db_operation_slow', {
    'table': table,
    'op': op,
    'duration_ms': durationMs,
  });

  @override
  void logQuranPlaybackStarted({
    required int surah,
    required String reciter,
    required String mode,
  }) => logEventInternal('quran_playback_started', {
    'surah': surah,
    'reciter': reciter,
    'mode': mode,
  });

  @override
  void logQuranPlaybackCompleted({
    required int surah,
    required int durationSeconds,
    required bool wasCompleted,
  }) => logEventInternal('quran_playback_completed', {
    'surah': surah,
    'duration_seconds': durationSeconds,
    'was_completed': wasCompleted.toString(),
  });
}
