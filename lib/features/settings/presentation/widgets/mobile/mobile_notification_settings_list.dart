import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../injection.dart';
import '../../../domain/entities/prayer_sound_mode.dart';
import '../../bloc/adhan_preview_cubit.dart';
import '../../bloc/custom_adhan_cubit.dart';
import '../../settings_provider.dart';
import 'mobile_adhan_sound_dialog.dart';
import 'mobile_adhkar_notification_section.dart';
import 'mobile_al_kahf_notification_section.dart';
import 'mobile_notification_master_toggle.dart';
import 'mobile_notification_settings_header.dart';
import 'mobile_prayer_notification_list.dart';
import 'mobile_pre_adhan_duration_dialog.dart';
import 'mobile_settings_section_title.dart';
import 'mobile_settings_tile.dart';

class MobileNotificationSettingsList extends StatelessWidget {
  const MobileNotificationSettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sp = context.watch<SettingsProvider>();
    final s = sp.settings;
    final isMasterOn = s.adhanMode == PrayerSoundMode.sound;

    return Column(
      children: [
        const MobileNotificationSettingsHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Master toggle (hero) — at top because it gates the
              //    prayer-adhan rows below it.
              MobileNotificationMasterToggle(
                isOn: isMasterOn,
                onChanged: (v) => sp.updateAdhanMode(
                  v ? PrayerSoundMode.sound : PrayerSoundMode.off,
                ),
              ),
              const SizedBox(height: 12),

              // 2. Diagnostic shortcut.
              MobileSettingsTile(
                icon: Icons.health_and_safety_outlined,
                title: 'صحة الإشعارات',
                subtitle: 'تشخيص ومعالجة مشاكل وصول الإشعارات',
                onTap: () => _openHealthScreen(context),
              ),

              // 3. Daily reminders (independent of master adhan toggle).
              const SizedBox(height: 22),
              const MobileAdhkarNotificationSection(),
              const SizedBox(height: 18),
              const MobileAlKahfNotificationSection(),

              // 4. Adhan sound + per-prayer alerts — gated by master toggle.
              const SizedBox(height: 22),
              MobileSettingsSectionTitle(
                title: l.settingsGeneralSettings,
                icon: Icons.settings_outlined,
              ),
              MobileSettingsTile(
                icon: Icons.music_note_rounded,
                title: l.settingsAdhanSoundLabel,
                onTap: () => _showAdhanSoundPicker(context, sp, s.adhanSound),
              ),
              const SizedBox(height: 22),
              MobileSettingsSectionTitle(
                title: l.settingsPrayerAlerts,
                icon: Icons.mosque_rounded,
              ),
              MobilePrayerNotificationList(
                isMasterOn: isMasterOn,
                onPreAdhanDurationTap: () =>
                    _showDurationPicker(context, sp, 'adhan'),
                onPreIqamaDurationTap: () =>
                    _showDurationPicker(context, sp, 'iqama'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAdhanSoundPicker(
    BuildContext context,
    SettingsProvider sp,
    String current,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<AdhanPreviewCubit>()),
          BlocProvider(
            create: (_) => CustomAdhanCubit(
              import: getIt(),
              delete: getIt(),
              settings: sp,
            ),
          ),
        ],
        child: MobileAdhanSoundDialog(
          currentSound: current,
          onSave: (key) => sp.updateAdhanSound(key),
        ),
      ),
    );
  }

  void _showDurationPicker(
    BuildContext context,
    SettingsProvider sp,
    String type,
  ) {
    final l = AppLocalizations.of(context);
    final s = context.read<SettingsProvider>().settings;
    final isAdhan = type == 'adhan';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MobilePreAdhanDurationDialog(
        title: isAdhan
            ? l.settingsPreAdhanDuration
            : l.settingsPreIqamaDuration,
        currentMinutes: isAdhan
            ? s.preAdhanReminderMinutes
            : s.preIqamaReminderMinutes,
        onSave: isAdhan
            ? (min) => sp.updatePreAdhanReminderMinutes(min)
            : (min) => sp.updatePreIqamaReminderMinutes(min),
      ),
    );
  }

  void _openHealthScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/notification_health');
  }
}
