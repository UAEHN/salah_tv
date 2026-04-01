import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import 'mobile_notification_toggle_row.dart';

const _prayerIcons = {
  'fajr': Icons.nights_stay_outlined,
  'dhuhr': Icons.light_mode_outlined,
  'asr': Icons.wb_sunny_outlined,
  'maghrib': Icons.wb_twilight_rounded,
  'isha': Icons.stars_outlined,
};

/// Per-prayer notification card with 4 toggle rows.
class MobilePrayerNotificationCard extends StatelessWidget {
  final String prayerKey;
  final String prayerName;
  final bool isAdhanOn;
  final bool isPreAdhanOn;
  final bool isIqamaOn;
  final bool isPreIqamaOn;
  final bool isEnabled;
  final int preAdhanMinutes;
  final int preIqamaMinutes;
  final ValueChanged<bool> onAdhanChanged;
  final ValueChanged<bool> onPreAdhanChanged;
  final ValueChanged<bool> onIqamaChanged;
  final ValueChanged<bool> onPreIqamaChanged;
  final VoidCallback onPreAdhanDurationTap;
  final VoidCallback onPreIqamaDurationTap;

  const MobilePrayerNotificationCard({
    super.key,
    required this.prayerKey,
    required this.prayerName,
    required this.isAdhanOn,
    required this.isPreAdhanOn,
    required this.isIqamaOn,
    required this.isPreIqamaOn,
    required this.isEnabled,
    required this.preAdhanMinutes,
    required this.preIqamaMinutes,
    required this.onAdhanChanged,
    required this.onPreAdhanChanged,
    required this.onIqamaChanged,
    required this.onPreIqamaChanged,
    required this.onPreAdhanDurationTap,
    required this.onPreIqamaDurationTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cardColor = MobileColors.cardColor(context);

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MobileColors.border(context).withValues(alpha: 0.7),
          ),
          boxShadow: MobileShadows.sleekCard(context),
        ),
        child: Column(
          children: [
            _PrayerHeader(prayerKey: prayerKey, prayerName: prayerName),
            const SizedBox(height: 12),
            MobileNotificationToggleRow(
              label: l.settingsPreAdhanReminder,
              value: isPreAdhanOn,
              isEnabled: isEnabled,
              onChanged: onPreAdhanChanged,
            ),
            if (isPreAdhanOn && isEnabled)
              MobileReminderDurationChip(
                label: l.settingsBeforeMinutes(preAdhanMinutes),
                onTap: onPreAdhanDurationTap,
              ),
            MobileNotificationToggleRow(
              label: l.settingsAdhanAlert,
              value: isAdhanOn,
              isEnabled: isEnabled,
              onChanged: onAdhanChanged,
            ),
            MobileNotificationToggleRow(
              label: l.settingsPreIqamaReminder,
              value: isPreIqamaOn,
              isEnabled: isEnabled,
              onChanged: onPreIqamaChanged,
            ),
            if (isPreIqamaOn && isEnabled)
              MobileReminderDurationChip(
                label: l.settingsBeforeMinutes(preIqamaMinutes),
                onTap: onPreIqamaDurationTap,
              ),
            MobileNotificationToggleRow(
              label: l.settingsIqamaAlert,
              value: isIqamaOn,
              isEnabled: isEnabled,
              onChanged: onIqamaChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerHeader extends StatelessWidget {
  final String prayerKey;
  final String prayerName;

  const _PrayerHeader({required this.prayerKey, required this.prayerName});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          _prayerIcons[prayerKey] ?? Icons.access_time,
          color: MobileColors.primaryContainer,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          prayerName,
          style: MobileTextStyles.headlineMd(context).copyWith(
            color: MobileColors.onSurface(context),
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}
