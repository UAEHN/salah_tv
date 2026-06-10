import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../prayer/domain/entities/daily_prayer_times.dart';
import '../../settings/domain/entities/app_settings.dart';
import 'notification_channel_resolver.dart';
import 'notification_payload_factory.dart';

/// Builds the JSON the native engine consumes via `MethodChannel.invoke('sync')`.
/// Output schema mirrors `EngineSyncRequest` on the Kotlin side.
///
/// Per-notification assembly lives in [NotificationPayloadFactory] so neither
/// file exceeds the 150-line cap and the schema concerns stay separate from
/// the time/title/body construction.
class NotificationSerializer {
  final NotificationChannelResolver _channels;
  final NotificationPayloadFactory _factory;

  NotificationSerializer({
    NotificationChannelResolver? channels,
    NotificationPayloadFactory? factory,
  }) : _channels = channels ?? NotificationChannelResolver(),
       _factory = factory ?? NotificationPayloadFactory();

  String build(List<DailyPrayerTimes> days, AppSettings settings) {
    final l = lookupAppLocalizations(Locale(settings.locale));
    final adhan = _channels.resolveAdhan(settings);
    final notifications = <Map<String, Object?>>[];
    for (var i = 0; i < days.length; i++) {
      _factory.addForDay(notifications, days[i], i, settings, l, adhan);
    }
    return jsonEncode({
      'notifications': notifications,
      'customAdhans': _customAdhansPayload(settings),
      'meta': {'horizonDays': days.length, 'locale': settings.locale},
    });
  }

  List<Map<String, String>> _customAdhansPayload(AppSettings s) => s
      .customAdhans
      .where((c) => c.contentUri.isNotEmpty)
      .map((c) => {'fileName': c.fileName, 'contentUri': c.contentUri})
      .toList(growable: false);
}
