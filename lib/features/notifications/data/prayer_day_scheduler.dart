import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/localization/prayer_name_localizer.dart';
import '../../prayer/domain/entities/daily_prayer_times.dart';
import '../../settings/domain/entities/app_settings.dart';

/// Schedules all notification types for a single day's prayer times.
/// ID layout: adhan [base+0..4], pre-adhan [base+10..14],
///            iqama [base+20..24], pre-iqama [base+30..34].
/// Pass [idBase]=0 for today, [idBase]=40 for tomorrow.
class PrayerDayScheduler {
  static const _keys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
  static const _keyIndex = {
    'fajr': 0, 'dhuhr': 1, 'asr': 2, 'maghrib': 3, 'isha': 4,
  };

  final FlutterLocalNotificationsPlugin _plugin;

  const PrayerDayScheduler(this._plugin);

  Future<void> schedule(
    DailyPrayerTimes prayers,
    AppSettings settings,
    int idBase,
    NotificationDetails adhanN,
    NotificationDetails reminderN,
    NotificationDetails iqamaN,
    NotificationDetails preIqamaN,
    AppLocalizations l,
    DateTime now,
  ) async {
    for (final entry in prayers.prayersOnly) {
      if (!_keys.contains(entry.key)) continue;
      if (settings.prayerNotificationEnabled[entry.key] == false) continue;
      final base = idBase + (_keyIndex[entry.key] ?? 0);

      final offset = settings.adhanOffsets[entry.key] ?? 0;
      final adhanTime = entry.time.add(Duration(minutes: offset));
      final prayerName = localizedPrayerNameForLocale(settings.locale, entry.key);

      await _schedule(base, prayerName, l.notificationAdhanBody(prayerName),
          adhanTime, adhanN, now);

      if (settings.preAdhanReminderEnabled[entry.key] == true) {
        final t = adhanTime.subtract(
          Duration(minutes: settings.preAdhanReminderMinutes),
        );
        await _schedule(
          base + 10,
          l.notificationReminderTitle,
          l.notificationPreAdhanBody(prayerName, settings.preAdhanReminderMinutes),
          t, reminderN, now,
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
          l.notificationPreIqamaBody(prayerName, settings.preIqamaReminderMinutes),
          t, preIqamaN, now,
        );
      }

      if (settings.iqamaNotificationEnabled[entry.key] == true) {
        await _schedule(
          base + 20,
          l.notificationIqamaTitle,
          l.notificationIqamaBody(prayerName),
          iqamaTime, iqamaN, now,
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
      utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second,
    );
    try {
      await _plugin.zonedSchedule(
        id, title, body, t, details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on Exception catch (e) {
      debugPrint('[Notification] schedule id=$id failed: $e');
    }
  }
}
