import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/mobile_theme.dart';
import '../../settings_provider.dart';
import 'mobile_notification_reminder_row.dart';
import 'mobile_settings_section_title.dart';

/// Morning + evening adhkar reminder section in the mobile notification page.
/// Two single-row reminders: each row hosts the label, an inline time chip
/// (only visible when enabled), and a switch.
class MobileAdhkarNotificationSection extends StatelessWidget {
  const MobileAdhkarNotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sp = context.watch<SettingsProvider>();
    final s = sp.settings;
    final cardColor = MobileColors.cardColor(context);

    return Column(
      children: [
        MobileSettingsSectionTitle(
          title: l.settingsAdhkarNotificationsTitle,
          icon: Icons.auto_stories_rounded,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: MobileColors.border(context).withValues(alpha: 0.7),
            ),
            boxShadow: MobileShadows.sleekCard(context),
          ),
          child: Column(
            children: [
              MobileNotificationReminderRow(
                icon: Icons.wb_sunny_outlined,
                label: l.settingsMorningAdhkarToggle,
                isOn: s.isMorningAdhkarNotificationEnabled,
                minuteOfDay: s.morningAdhkarMinuteOfDay,
                pickerTitle: l.settingsAdhkarOffsetTitle,
                onChanged: sp.updateMorningAdhkarNotification,
                onPickTime: sp.updateMorningAdhkarMinuteOfDay,
                showDivider: true,
              ),
              MobileNotificationReminderRow(
                icon: Icons.nights_stay_outlined,
                label: l.settingsEveningAdhkarToggle,
                isOn: s.isEveningAdhkarNotificationEnabled,
                minuteOfDay: s.eveningAdhkarMinuteOfDay,
                pickerTitle: l.settingsAdhkarOffsetTitle,
                onChanged: sp.updateEveningAdhkarNotification,
                onPickTime: sp.updateEveningAdhkarMinuteOfDay,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
