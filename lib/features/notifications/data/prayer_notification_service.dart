import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../core/adhan_sounds.dart';
import '../../../core/localization/prayer_name_localizer.dart';
import '../../../features/prayer/domain/entities/daily_prayer_times.dart';
import '../domain/i_prayer_notification_port.dart';
import '../../../features/settings/domain/entities/app_settings.dart';
import 'notification_channels.dart';

/// Schedules local notifications for prayers.
/// IDs: adhan 0–4, pre-adhan 10–14, iqama 20–24, pre-iqama 30–34.
class PrayerNotificationService implements IPrayerNotificationPort {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _ids = {
    'fajr': 0,
    'dhuhr': 1,
    'asr': 2,
    'maghrib': 3,
    'isha': 4,
  };

  @override
  Future<void> initialize() async {
    tz.initializeTimeZones();
    const init = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: init));
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await NotificationChannels.createAll(android);
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  @override
  Future<void> scheduleForDay(
    DailyPrayerTimes prayers,
    AppSettings settings,
  ) async {
    await cancelAll();
    // playAdhan controls TV audio only — notifications are scheduled independently.
    if (settings.prayerNotificationEnabled.values.every((v) => !v)) return;
    final l = lookupAppLocalizations(Locale(settings.locale));
    final now = DateTime.now();
    final sound = kAdhanSounds.firstWhere(
      (s) => s.key == settings.adhanSound,
      orElse: () => kAdhanSounds.first,
    );
    final raw = NotificationChannels.rawName(sound.asset);
    final adhanN = NotificationDetails(
      android: NotificationChannels.adhanDetails(raw),
    );
    final reminderN = NotificationDetails(
      android: NotificationChannels.silentDetails(
        NotificationChannels.reminderChId,
        l.notificationReminderTitle,
      ),
    );
    final iqamaN = NotificationDetails(
      android: NotificationChannels.silentDetails(
        NotificationChannels.iqamaChId,
        l.notificationIqamaTitle,
      ),
    );
    final preIqamaN = NotificationDetails(
      android: NotificationChannels.silentDetails(
        NotificationChannels.preIqamaChId,
        l.notificationReminderTitle,
      ),
    );

    for (final entry in prayers.prayersOnly) {
      final base = _ids[entry.key];
      if (base == null) continue;
      if (settings.prayerNotificationEnabled[entry.key] == false) continue;

      final offset = settings.adhanOffsets[entry.key] ?? 0;
      final adhanTime = entry.time.add(Duration(minutes: offset));
      final prayerName = localizedPrayerNameForLocale(
        settings.locale,
        entry.key,
      );

      await _schedule(
        base,
        prayerName,
        l.notificationAdhanBody(prayerName),
        adhanTime,
        adhanN,
        now,
      );

      if (settings.preAdhanReminderEnabled[entry.key] == true) {
        final t = adhanTime.subtract(
          Duration(minutes: settings.preAdhanReminderMinutes),
        );
        await _schedule(
          base + 10,
          l.notificationReminderTitle,
          l.notificationPreAdhanBody(
            prayerName,
            settings.preAdhanReminderMinutes,
          ),
          t,
          reminderN,
          now,
        );
      }

      final iqamaTime = adhanTime.add(
        Duration(minutes: settings.iqamaDelays[entry.key] ?? 10),
      );

      if (settings.preIqamaReminderEnabled[entry.key] == true) {
        final t = iqamaTime.subtract(
          Duration(minutes: settings.preIqamaReminderMinutes),
        );
        await _schedule(
          base + 30,
          l.notificationReminderTitle,
          l.notificationPreIqamaBody(
            prayerName,
            settings.preIqamaReminderMinutes,
          ),
          t,
          preIqamaN,
          now,
        );
      }

      if (settings.iqamaNotificationEnabled[entry.key] == true) {
        await _schedule(
          base + 20,
          l.notificationIqamaTitle,
          l.notificationIqamaBody(prayerName),
          iqamaTime,
          iqamaN,
          now,
        );
      }
    }
  }

  Future<void> _schedule(
    int id,
    String title,
    String body,
    DateTime time,
    NotificationDetails details,
    DateTime now,
  ) async {
    if (time.isBefore(now)) return;
    final utc = time.toUtc();
    final t = tz.TZDateTime.utc(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
    );
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        t,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on Exception catch (e) {
      debugPrint('[Notification] schedule id=$id failed: $e');
    }
  }

  @override
  Future<void> cancelAll() async {
    for (final id in _ids.values) {
      await _plugin.cancel(id);
      await _plugin.cancel(id + 10);
      await _plugin.cancel(id + 20);
      await _plugin.cancel(id + 30);
    }
  }
}
