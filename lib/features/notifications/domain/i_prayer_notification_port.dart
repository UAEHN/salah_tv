import '../../prayer/domain/entities/daily_prayer_times.dart';
import '../../settings/domain/entities/app_settings.dart';

/// Domain port: schedules local notifications for prayer times.
/// Implemented in features/notifications/data/ to keep domain pure.
/// Nullable in [PrayerCycleBase] — only registered on mobile, not TV.
abstract class IPrayerNotificationPort {
  /// One-time init: sets up notification channel + requests permission.
  Future<void> initialize();

  /// Cancels all pending notifications then schedules today's 5 prayers.
  /// [settings] provides adhanOffsets for adjusted times.
  Future<void> scheduleForDay(DailyPrayerTimes prayers, AppSettings settings);

  /// Cancels all pending prayer notifications (e.g. before rescheduling).
  Future<void> cancelAll();
}
