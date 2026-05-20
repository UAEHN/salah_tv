import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/mobile_theme.dart';
import '../../settings_provider.dart';
import 'mobile_notification_toggle_row.dart';
import 'mobile_settings_section_title.dart';

/// Morning + evening adhkar reminder section in the mobile notification page.
/// Two toggles + two TimePicker chips. The user freely picks any wall-clock
/// time for each reminder.
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
        const SizedBox(height: 24),
        MobileSettingsSectionTitle(
          title: l.settingsAdhkarNotificationsTitle,
          icon: Icons.auto_stories_rounded,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MobileColors.border(context).withValues(alpha: 0.7),
            ),
            boxShadow: MobileShadows.sleekCard(context),
          ),
          child: Column(
            children: [
              MobileNotificationToggleRow(
                label: l.settingsMorningAdhkarToggle,
                value: s.isMorningAdhkarNotificationEnabled,
                isEnabled: true,
                onChanged: sp.updateMorningAdhkarNotification,
              ),
              if (s.isMorningAdhkarNotificationEnabled)
                _TimeChip(
                  minuteOfDay: s.morningAdhkarMinuteOfDay,
                  onPick: (m) => sp.updateMorningAdhkarMinuteOfDay(m),
                  pickerTitle: l.settingsAdhkarOffsetTitle,
                ),
              MobileNotificationToggleRow(
                label: l.settingsEveningAdhkarToggle,
                value: s.isEveningAdhkarNotificationEnabled,
                isEnabled: true,
                onChanged: sp.updateEveningAdhkarNotification,
              ),
              if (s.isEveningAdhkarNotificationEnabled)
                _TimeChip(
                  minuteOfDay: s.eveningAdhkarMinuteOfDay,
                  onPick: (m) => sp.updateEveningAdhkarMinuteOfDay(m),
                  pickerTitle: l.settingsAdhkarOffsetTitle,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final int minuteOfDay;
  final ValueChanged<int> onPick;
  final String pickerTitle;

  const _TimeChip({
    required this.minuteOfDay,
    required this.onPick,
    required this.pickerTitle,
  });

  @override
  Widget build(BuildContext context) {
    final hh = minuteOfDay ~/ 60;
    final mm = minuteOfDay % 60;
    final label = '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(right: 32, bottom: 6, top: 2),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _open(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MobileColors.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MobileColors.primaryContainer.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: MobileColors.primaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: MobileTextStyles.bodyMd(context).copyWith(
                      color: MobileColors.primaryContainer,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60),
      helpText: pickerTitle,
    );
    if (picked != null) onPick(picked.hour * 60 + picked.minute);
  }
}
