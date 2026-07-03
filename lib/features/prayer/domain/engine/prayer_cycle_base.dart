import '../../../../core/diagnostics/app_diagnostics.dart';
import '../../../analytics/domain/i_analytics_service.dart';
import '../i_prayer_audio_port.dart';
import '../i_takbeerat_audio_port.dart';
import '../../../notifications/domain/i_prayer_notification_port.dart';
import '../i_prayer_times_repository.dart';
import '../i_session_adhkar_log_port.dart';
import '../../../settings/domain/entities/app_settings.dart';
import 'prayer_cycle_state.dart';

/// Abstract base that all [PrayerCycleEngine] mixins constrain on.
/// Exposes the shared state container and injected dependencies so every
/// mixin can operate on them without coupling to the concrete engine class.
abstract class PrayerCycleBase {
  PrayerCycleState get s;
  IPrayerAudioPort get audio;
  ITakbeeratAudioPort get takbeeratAudio;
  IPrayerTimesRepository get repo;
  AppSettings get settings;
  set settings(AppSettings value);
  void Function() get notify;
  DateTime currentTime();

  /// Null on TV — notifications are mobile-only.
  IPrayerNotificationPort? get notifications;

  /// Persists which session-adhkar categories were shown today so the app-open
  /// catch-up survives a full restart. Nullable so tests/mocks can omit it;
  /// when null the catch-up dedup falls back to the in-memory set only.
  ISessionAdhkarLogPort? get sessionAdhkarLog;

  /// Nullable so legacy tests / mocks can build the engine without analytics.
  /// In production it is always injected by [PrayerBloc]. All call sites
  /// MUST use the null-safe `analytics?.log...` pattern — telemetry must
  /// never break the prayer cycle (§8 CLAUDE.md).
  IAnalyticsService? get analytics;

  /// Local + remote diagnostic event sink. Nullable for tests; production
  /// injects it so adhan/iqama/audio failures leave a device-local trail.
  AppDiagnostics? get diagnostics;
}
