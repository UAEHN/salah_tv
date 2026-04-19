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

  /// Derives a stable channel id from a custom adhan file name. Stripping
  /// the extension keeps the id identical if the same file is later re-
  /// imported, so the user keeps their channel-level preferences (DND
  /// bypass, badge, etc.).
  static String customAdhanChannelId(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final stem = dot > 0 ? fileName.substring(0, dot) : fileName;
    return 'prayer_times_v5_custom_$stem';
  }

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

  static AndroidNotificationDetails adhanDetailsCustom(
    String channelId,
    String contentUri,
  ) => AndroidNotificationDetails(
    channelId,
    adhanChannelName,
    channelDescription: adhanChannelDesc,
    importance: Importance.max,
    priority: Priority.max,
    sound: UriAndroidNotificationSound(contentUri),
    playSound: true,
    enableVibration: true,
    category: AndroidNotificationCategory.alarm,
  );

  /// Creates the channel for a custom adhan sound if it doesn't exist yet.
  /// Android caches channel settings permanently — once a channel is created
  /// its sound URI cannot change, so each distinct file gets its own id.
  static Future<void> ensureCustomAdhanChannel(
    AndroidFlutterLocalNotificationsPlugin? android,
    String channelId,
    String contentUri,
  ) async {
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        channelId,
        adhanChannelName,
        description: adhanChannelDesc,
        importance: Importance.max,
        sound: UriAndroidNotificationSound(contentUri),
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );
  }

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
