import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../features/prayer/domain/entities/daily_prayer_times.dart';
import '../domain/i_prayer_notification_port.dart';
import '../../../features/settings/domain/entities/app_settings.dart';
import 'adhan_notification_sound.dart';
import 'notification_channels.dart';
import 'prayer_day_scheduler.dart';

/// Schedules local notifications for prayers.
/// IDs per day: adhan 0–4, pre-adhan 10–14, iqama 20–24, pre-iqama 30–34.
/// Tomorrow uses the same layout offset by +40 (40–44, 50–54, 60–64, 70–74).
class PrayerNotificationService implements IPrayerNotificationPort {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final AdhanNotificationSound _soundResolver = const AdhanNotificationSound();

  static const _todayBase = 0;
  static const _tomorrowBase = 40;

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
    await _requestBatteryOptimizationExemption();
  }

  /// Requests the system dialog to exempt this app from battery optimization.
  /// Without exemption, OEM ROMs (Xiaomi/Huawei/Samsung) can kill AlarmManager
  /// entries even when exactAllowWhileIdle is set, stopping all notifications.
  Future<void> _requestBatteryOptimizationExemption() async {
    const ch = MethodChannel('ghasaq/platform');
    try {
      final ignored =
          await ch.invokeMethod<bool>('isBatteryOptimizationIgnored') ?? true;
      if (!ignored) {
        await ch.invokeMethod<void>('requestIgnoreBatteryOptimization');
      }
    } on PlatformException catch (e) {
      debugPrint('[Notification] battery opt check failed: $e');
    }
  }

  @override
  Future<void> scheduleForDay(
    DailyPrayerTimes today,
    DailyPrayerTimes? tomorrow,
    AppSettings settings,
  ) async {
    await cancelAll();
    if (settings.prayerNotificationEnabled.values.every((v) => !v)) return;

    final l = lookupAppLocalizations(Locale(settings.locale));
    final now = DateTime.now();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final adhanDetails = await _soundResolver.resolve(settings, android);
    final adhanN = NotificationDetails(android: adhanDetails);
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

    final scheduler = PrayerDayScheduler(_plugin);
    final args = (settings, adhanN, reminderN, iqamaN, preIqamaN, l, now);

    await scheduler.schedule(today, args.$1, _todayBase,
        args.$2, args.$3, args.$4, args.$5, args.$6, args.$7);

    if (tomorrow != null) {
      await scheduler.schedule(tomorrow, args.$1, _tomorrowBase,
          args.$2, args.$3, args.$4, args.$5, args.$6, args.$7);
    }
  }

  @override
  Future<void> cancelAll() async {
    for (var i = 0; i < 5; i++) {
      for (final base in [_todayBase, _tomorrowBase]) {
        await _plugin.cancel(base + i);
        await _plugin.cancel(base + i + 10);
        await _plugin.cancel(base + i + 20);
        await _plugin.cancel(base + i + 30);
      }
    }
  }
}
