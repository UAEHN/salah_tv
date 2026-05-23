import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../settings_provider.dart';
import 'mobile_prayer_notification_card.dart';

const _prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

/// Stacks the five per-prayer notification cards (Fajr → Isha) with
/// consistent vertical spacing. Each card stays gated by [isMasterOn].
class MobilePrayerNotificationList extends StatelessWidget {
  final bool isMasterOn;
  final VoidCallback onPreAdhanDurationTap;
  final VoidCallback onPreIqamaDurationTap;

  const MobilePrayerNotificationList({
    super.key,
    required this.isMasterOn,
    required this.onPreAdhanDurationTap,
    required this.onPreIqamaDurationTap,
  });

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final s = sp.settings;

    return Column(
      children: _prayerKeys.map((prayerKey) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MobilePrayerNotificationCard(
            prayerKey: prayerKey,
            prayerName: localizedPrayerName(context, prayerKey),
            isAdhanOn: s.prayerNotificationEnabled[prayerKey] ?? true,
            isPreAdhanOn: s.preAdhanReminderEnabled[prayerKey] ?? false,
            isIqamaOn: s.iqamaNotificationEnabled[prayerKey] ?? false,
            isPreIqamaOn: s.preIqamaReminderEnabled[prayerKey] ?? false,
            isEnabled: isMasterOn,
            preAdhanMinutes: s.preAdhanReminderMinutes,
            preIqamaMinutes: s.preIqamaReminderMinutes,
            onAdhanChanged: (v) =>
                sp.updatePrayerNotificationEnabled(prayerKey, v),
            onPreAdhanChanged: (v) =>
                sp.updatePreAdhanReminderEnabled(prayerKey, v),
            onIqamaChanged: (v) =>
                sp.updateIqamaNotificationEnabled(prayerKey, v),
            onPreIqamaChanged: (v) =>
                sp.updatePreIqamaReminderEnabled(prayerKey, v),
            onPreAdhanDurationTap: onPreAdhanDurationTap,
            onPreIqamaDurationTap: onPreIqamaDurationTap,
          ),
        );
      }).toList(),
    );
  }
}
