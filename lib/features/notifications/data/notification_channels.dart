import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/adhan_sounds.dart';

/// Channel IDs and initialization for prayer notification channels.
class NotificationChannels {
  static const adhanChannelName = 'Prayer times';
  static const adhanChannelDesc = 'Notifications for the five daily prayers';
  static const reminderChId = 'prayer_reminder_v1';
  static const iqamaChId = 'prayer_iqama_v1';
  static const preIqamaChId = 'prayer_pre_iqama_v1';

  static String rawName(String asset) =>
      asset.split('/').last.replaceAll(RegExp(r'\.\w+$'), '');

  static String adhanChannelId(String raw) => 'prayer_times_v5_$raw';

  static AndroidNotificationDetails adhanDetails(String raw) =>
      AndroidNotificationDetails(
        adhanChannelId(raw),
        adhanChannelName,
        channelDescription: adhanChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        sound: RawResourceAndroidNotificationSound(raw),
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
      );

  static AndroidNotificationDetails silentDetails(String id, String name) =>
      AndroidNotificationDetails(
        id,
        name,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
      );

  static Future<void> createAll(
    AndroidFlutterLocalNotificationsPlugin? android,
  ) async {
    for (final sound in kAdhanSounds) {
      final raw = rawName(sound.asset);
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          adhanChannelId(raw),
          adhanChannelName,
          description: adhanChannelDesc,
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound(raw),
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
    }

    for (final ch in [
      (reminderChId, 'Pre-adhan reminder', 'Reminder before adhan time'),
      (iqamaChId, 'Iqama alert', 'Alert when iqama time starts'),
      (preIqamaChId, 'Pre-iqama reminder', 'Reminder before iqama time'),
    ]) {
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          ch.$1,
          ch.$2,
          description: ch.$3,
          importance: Importance.high,
        ),
      );
    }
  }
}
