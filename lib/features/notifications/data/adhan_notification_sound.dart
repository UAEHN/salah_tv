import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/adhan_sounds.dart';
import '../../settings/domain/entities/app_settings.dart';
import '../../settings/domain/entities/custom_adhan.dart';
import 'notification_channels.dart';

/// Resolves [AndroidNotificationDetails] for an adhan notification. Built-in
/// sounds map to raw resources; custom sounds are played via the MediaStore
/// content URI already stored on [CustomAdhan.contentUri] (published at
/// import time). Android caches channel sound forever, so every file gets
/// its own channel id keyed by the file basename.
class AdhanNotificationSound {
  const AdhanNotificationSound();

  Future<AndroidNotificationDetails> resolve(
    AppSettings settings,
    AndroidFlutterLocalNotificationsPlugin? android,
  ) async {
    final custom = await _tryResolveCustom(settings, android);
    if (custom != null) return custom;
    final fallback = kAdhanSounds.firstWhere(
      (s) => s.key == settings.adhanSound,
      orElse: () => kAdhanSounds.first,
    );
    return NotificationChannels.adhanDetails(
      NotificationChannels.rawName(fallback.asset),
    );
  }

  Future<AndroidNotificationDetails?> _tryResolveCustom(
    AppSettings settings,
    AndroidFlutterLocalNotificationsPlugin? android,
  ) async {
    final fileName = CustomAdhan.extractFileName(settings.adhanSound);
    if (fileName == null) return null;
    final entry = settings.customAdhans
        .where((c) => c.fileName == fileName)
        .firstOrNull;
    if (entry == null || entry.contentUri.isEmpty) return null;
    final channelId = NotificationChannels.customAdhanChannelId(fileName);
    await NotificationChannels.ensureCustomAdhanChannel(
      android,
      channelId,
      entry.contentUri,
    );
    return NotificationChannels.adhanDetailsCustom(channelId, entry.contentUri);
  }
}
