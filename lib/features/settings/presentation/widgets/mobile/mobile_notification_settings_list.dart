import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings_provider.dart';
import 'mobile_adhan_sound_dialog.dart';
import 'mobile_notification_master_toggle.dart';
import 'mobile_notification_settings_header.dart';
import 'mobile_prayer_notification_card.dart';
import 'mobile_pre_adhan_duration_dialog.dart';
import 'mobile_settings_section_title.dart';
import 'mobile_settings_tile.dart';

const _prayers = [
  ('fajr', 'الفجر'),
  ('dhuhr', 'الظهر'),
  ('asr', 'العصر'),
  ('maghrib', 'المغرب'),
  ('isha', 'العشاء'),
];

class MobileNotificationSettingsList extends StatelessWidget {
  const MobileNotificationSettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final s = sp.settings;
    final isMasterOn = s.playAdhan;

    return Column(
      children: [
        const MobileNotificationSettingsHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
            physics: const BouncingScrollPhysics(),
            children: [
              MobileNotificationMasterToggle(
                isOn: isMasterOn,
                onChanged: (v) => sp.updatePlayAdhan(v),
              ),
              const SizedBox(height: 16),
              const MobileSettingsSectionTitle(
                title: 'إعدادات عامة',
                icon: Icons.settings_outlined,
              ),
              MobileSettingsTile(
                title: 'صوت الأذان',
                onTap: () => _showAdhanSoundPicker(context, sp, s.adhanSound),
              ),
              const SizedBox(height: 24),
              const MobileSettingsSectionTitle(
                title: 'تنبيهات الصلوات',
                icon: Icons.mosque_rounded,
              ),
              ..._prayers.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MobilePrayerNotificationCard(
                  prayerKey: p.$1,
                  prayerName: p.$2,
                  isAdhanOn: s.prayerNotificationEnabled[p.$1] ?? true,
                  isPreAdhanOn: s.preAdhanReminderEnabled[p.$1] ?? false,
                  isIqamaOn: s.iqamaNotificationEnabled[p.$1] ?? false,
                  isPreIqamaOn: s.preIqamaReminderEnabled[p.$1] ?? false,
                  isEnabled: isMasterOn,
                  preAdhanMinutes: s.preAdhanReminderMinutes,
                  preIqamaMinutes: s.preIqamaReminderMinutes,
                  onAdhanChanged: (v) =>
                      sp.updatePrayerNotificationEnabled(p.$1, v),
                  onPreAdhanChanged: (v) =>
                      sp.updatePreAdhanReminderEnabled(p.$1, v),
                  onIqamaChanged: (v) =>
                      sp.updateIqamaNotificationEnabled(p.$1, v),
                  onPreIqamaChanged: (v) =>
                      sp.updatePreIqamaReminderEnabled(p.$1, v),
                  onPreAdhanDurationTap: () =>
                      _showDurationPicker(context, sp, 'adhan'),
                  onPreIqamaDurationTap: () =>
                      _showDurationPicker(context, sp, 'iqama'),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  void _showAdhanSoundPicker(
    BuildContext context, SettingsProvider sp, String current,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MobileAdhanSoundDialog(
        currentSound: current,
        onSave: (key) => sp.updateAdhanSound(key),
      ),
    );
  }

  void _showDurationPicker(
    BuildContext context, SettingsProvider sp, String type,
  ) {
    final s = context.read<SettingsProvider>().settings;
    final isAdhan = type == 'adhan';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MobilePreAdhanDurationDialog(
        title: isAdhan ? 'مدة التذكير قبل الأذان' : 'مدة التذكير قبل الإقامة',
        currentMinutes: isAdhan
            ? s.preAdhanReminderMinutes
            : s.preIqamaReminderMinutes,
        onSave: isAdhan
            ? (min) => sp.updatePreAdhanReminderMinutes(min)
            : (min) => sp.updatePreIqamaReminderMinutes(min),
      ),
    );
  }
}
