import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../prayer/domain/entities/daily_prayer_times.dart';
import '../../settings/domain/entities/app_settings.dart';
import '../../settings/domain/entities/custom_adhan.dart';
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
    final iqama = _channels.resolveIqama(settings);
    // Pre-adhan sound is per-prayer, so resolve one channel per prayer up
    // front and hand the map to the factory (mirrors adhan/iqama tuples).
    final preAdhan = {
      for (final key in NotificationPayloadFactory.prayerKeys)
        key: _channels.resolvePreAdhan(settings, key),
    };
    final notifications = <Map<String, Object?>>[];
    for (var i = 0; i < days.length; i++) {
      _factory.addForDay(
        notifications,
        days[i],
        i,
        settings,
        l,
        adhan,
        iqama,
        preAdhan,
      );
    }
    return jsonEncode({
      'notifications': notifications,
      'customAdhans': _customSoundsPayload(settings.customAdhans),
      'customIqamas': _customSoundsPayload(settings.customIqamas),
      'meta': {'horizonDays': days.length, 'locale': settings.locale},
    });
  }

  List<Map<String, String>> _customSoundsPayload(List<CustomAdhan> customs) =>
      customs
          .where((c) => c.contentUri.isNotEmpty)
          .map((c) => {'fileName': c.fileName, 'contentUri': c.contentUri})
          .toList(growable: false);
}
