import '../../prayer/domain/entities/daily_prayer_times.dart';
import '../../settings/domain/entities/app_settings.dart';

/// Domain port: schedules local notifications for prayer times.
/// Implemented in features/notifications/data/ to keep domain pure.
/// Nullable in [PrayerCycleBase] — only registered on mobile, not TV.
abstract class IPrayerNotificationPort {
  /// One-time init: sets up notification channel + requests permission.
  Future<void> initialize();

  /// Cancels all pending notifications then schedules [today]'s prayers and,
  /// if provided, [tomorrow]'s prayers. Scheduling two days ahead guarantees
  /// notifications survive overnight app closures and device reboots: the boot
  /// receiver re-registers persisted alarms, which remain in the future as long
  /// as they were scheduled for the next day.
  Future<void> scheduleForDay(
    DailyPrayerTimes today,
    DailyPrayerTimes? tomorrow,
    AppSettings settings,
  );

  /// Cancels all pending prayer notifications (e.g. before rescheduling).
  Future<void> cancelAll();
}
