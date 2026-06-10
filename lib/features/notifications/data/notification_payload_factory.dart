import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../core/localization/prayer_name_localizer.dart';
import '../../prayer/domain/entities/daily_prayer_times.dart';
import '../../settings/domain/entities/app_settings.dart';
import 'notification_channel_resolver.dart';
import 'notification_id_policy.dart';
import 'notification_payload_dto.dart';

/// Builds the per-day list of notification payload maps consumed by
/// [NotificationSerializer]. Pulled out of the serializer so neither file
/// exceeds the 150-line limit and so the time/title/body assembly is
/// independently testable.
class NotificationPayloadFactory {
  static const _prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  void addForDay(
    List<Map<String, Object?>> out,
    DailyPrayerTimes day,
    int dayIndex,
    AppSettings s,
    AppLocalizations l,
    ({String channelId, String? contentUri}) adhan,
  ) {
    _addPrayerNotifications(out, day, dayIndex, s, l, adhan);
    _addAdhkarNotifications(out, day, dayIndex, s, l);
    _addAlKahfReminder(out, day, dayIndex, s, l);
  }

  void _addPrayerNotifications(
    List<Map<String, Object?>> out,
    DailyPrayerTimes day,
    int dayIndex,
    AppSettings s,
    AppLocalizations l,
    ({String channelId, String? contentUri}) adhan,
  ) {
    for (final entry in day.prayersOnly) {
      if (!_prayerKeys.contains(entry.key)) continue;
      final name = localizedPrayerNameForLocale(s.locale, entry.key);
      final adhanTime = entry.time.add(
        Duration(minutes: s.adhanOffsets[entry.key] ?? 0),
      );
      // Single-line notifications: the message lives in [title] and [body]
      // is empty. Android renders the title prominently on the lock screen,
      // and an empty body keeps the layout one-line — no duplicate text,
      // no auto-injected timestamp drama.
      if (s.prayerNotificationEnabled[entry.key] == true) {
        out.add(
          buildNotificationPayloadDto(
            id: NotificationIdPolicy.forPrayer(
              type: 'adhan',
              dayIndex: dayIndex,
              prayerKey: entry.key,
            ),
            type: 'adhan',
            time: adhanTime,
            title: l.notificationAdhanBody(name),
            body: '',
            channelId: adhan.channelId,
            soundUri: adhan.contentUri,
            dayIndex: dayIndex,
            prayerKey: entry.key,
          ),
        );
      }
      if (s.preAdhanReminderEnabled[entry.key] == true) {
        out.add(
          buildNotificationPayloadDto(
            id: NotificationIdPolicy.forPrayer(
              type: 'pre_adhan',
              dayIndex: dayIndex,
              prayerKey: entry.key,
            ),
            type: 'pre_adhan',
            time: adhanTime.subtract(
              Duration(minutes: s.preAdhanReminderMinutes),
            ),
            title: l.notificationPreAdhanBody(name, s.preAdhanReminderMinutes),
            body: '',
            channelId: NotificationChannelResolver.preAdhan,
            dayIndex: dayIndex,
            prayerKey: entry.key,
          ),
        );
      }
      final iqamaTime = adhanTime.add(
        Duration(minutes: s.iqamaDelays[entry.key] ?? 10),
      );
      if (s.preIqamaReminderEnabled[entry.key] == true) {
        out.add(
          buildNotificationPayloadDto(
            id: NotificationIdPolicy.forPrayer(
              type: 'pre_iqama',
              dayIndex: dayIndex,
              prayerKey: entry.key,
            ),
            type: 'pre_iqama',
            time: iqamaTime.subtract(
              Duration(minutes: s.preIqamaReminderMinutes),
            ),
            title: l.notificationPreIqamaBody(name, s.preIqamaReminderMinutes),
            body: '',
            channelId: NotificationChannelResolver.preIqama,
            dayIndex: dayIndex,
            prayerKey: entry.key,
          ),
        );
      }
      if (s.iqamaNotificationEnabled[entry.key] == true) {
        out.add(
          buildNotificationPayloadDto(
            id: NotificationIdPolicy.forPrayer(
              type: 'iqama',
              dayIndex: dayIndex,
              prayerKey: entry.key,
            ),
            type: 'iqama',
            time: iqamaTime,
            title: l.notificationIqamaBody(name),
            body: '',
            channelId: NotificationChannelResolver.iqama,
            dayIndex: dayIndex,
            prayerKey: entry.key,
          ),
        );
      }
    }
  }

  void _addAdhkarNotifications(
    List<Map<String, Object?>> out,
    DailyPrayerTimes day,
    int dayIndex,
    AppSettings s,
    AppLocalizations l,
  ) {
    final base = DateTime(day.date.year, day.date.month, day.date.day);
    if (s.isMorningAdhkarNotificationEnabled) {
      out.add(
        buildNotificationPayloadDto(
          id: NotificationIdPolicy.forAdhkar(
            type: 'adhkar_morning',
            dayIndex: dayIndex,
          ),
          type: 'adhkar_morning',
          time: base.add(Duration(minutes: s.morningAdhkarMinuteOfDay)),
          title: l.notificationMorningAdhkarBody,
          body: '',
          channelId: NotificationChannelResolver.adhkar,
          payload: 'adhkar:morning',
          dayIndex: dayIndex,
        ),
      );
    }
    if (s.isEveningAdhkarNotificationEnabled) {
      out.add(
        buildNotificationPayloadDto(
          id: NotificationIdPolicy.forAdhkar(
            type: 'adhkar_evening',
            dayIndex: dayIndex,
          ),
          type: 'adhkar_evening',
          time: base.add(Duration(minutes: s.eveningAdhkarMinuteOfDay)),
          title: l.notificationEveningAdhkarBody,
          body: '',
          channelId: NotificationChannelResolver.adhkar,
          payload: 'adhkar:evening',
          dayIndex: dayIndex,
        ),
      );
    }
  }

  /// Weekly Friday reminder to read Surah Al-Kahf. Only emits on Fridays
  /// within the 7-day horizon — the wider re-sync that runs daily guarantees
  /// next Friday lands in the window before the previous one expires.
  void _addAlKahfReminder(
    List<Map<String, Object?>> out,
    DailyPrayerTimes day,
    int dayIndex,
    AppSettings s,
    AppLocalizations l,
  ) {
    if (!s.isAlKahfReminderEnabled) return;
    if (day.date.weekday != DateTime.friday) return;
    final base = DateTime(day.date.year, day.date.month, day.date.day);
    out.add(
      buildNotificationPayloadDto(
        id: NotificationIdPolicy.forAdhkar(type: 'al_kahf', dayIndex: dayIndex),
        type: 'al_kahf',
        time: base.add(Duration(minutes: s.alKahfReminderMinuteOfDay)),
        title: l.notificationAlKahfTitle,
        body: l.notificationAlKahfBody,
        channelId: NotificationChannelResolver.alKahf,
        payload: 'al_kahf',
        dayIndex: dayIndex,
      ),
    );
  }
}
