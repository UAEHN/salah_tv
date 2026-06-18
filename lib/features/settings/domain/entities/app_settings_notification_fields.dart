import 'app_settings.dart';

/// Equality over only the fields that shape the scheduled prayer/iqama
/// notifications. The engine re-runs `scheduleForDay` whenever these change so
/// a toggled reminder (e.g. pre-adhan) takes effect immediately, instead of
/// waiting for the next day-load / app launch.
extension AppSettingsNotificationFields on AppSettings {
  bool notificationFieldsEqual(AppSettings other) =>
      adhanMode == other.adhanMode &&
      adhanSound == other.adhanSound &&
      prayerNotificationEnabled.toString() ==
          other.prayerNotificationEnabled.toString() &&
      preAdhanReminderEnabled.toString() ==
          other.preAdhanReminderEnabled.toString() &&
      preAdhanReminderMinutes == other.preAdhanReminderMinutes &&
      iqamaNotificationEnabled.toString() ==
          other.iqamaNotificationEnabled.toString() &&
      preIqamaReminderEnabled.toString() ==
          other.preIqamaReminderEnabled.toString() &&
      preIqamaReminderMinutes == other.preIqamaReminderMinutes;
}
