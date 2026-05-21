import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_config.dart';
import '../../../../../core/platform_launcher.dart';

import '../../../../../core/city_translations.dart';
import '../../screens/mobile_notification_settings_screen.dart';
import '../../screens/mobile_prayer_offsets_screen.dart';
import '../../settings_provider.dart';
import 'mobile_calculation_method_tile.dart';
import 'mobile_location_dialog_launcher.dart';
import 'mobile_madhab_dialog.dart';
import 'mobile_settings_appearance_section.dart';
import 'mobile_settings_header.dart';
import 'mobile_settings_section_title.dart';
import 'mobile_settings_tile.dart';

class MobileSettingsList extends StatelessWidget {
  const MobileSettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sp = context.watch<SettingsProvider>();
    final s = sp.settings;

    return Column(
      children: [
        const MobileSettingsHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
            physics: const BouncingScrollPhysics(),
            children: [
              MobileSettingsSectionTitle(
                title: l.settingsLocationSection,
                icon: Icons.location_on,
              ),
              MobileSettingsTile(
                title: l.settingsCountryAndCity,
                subtitle:
                    '${cityLabel(s.selectedCity, locale: l.localeName, countryKey: s.selectedCountry)}${l.localeComma} ${countryLabel(s.selectedCountry, locale: l.localeName)}',
                onTap: () => showMobileLocationDialog(context),
              ),
              const SizedBox(height: 24),
              MobileSettingsSectionTitle(
                title: l.settingsNotificationsSection,
                icon: Icons.notifications_active,
              ),
              MobileSettingsTile(
                title: l.settingsNotificationSettings,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MobileNotificationSettingsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              MobileSettingsSectionTitle(
                title: l.settingsCalculationSection,
                icon: Icons.calculate_rounded,
              ),
              MobileCalculationMethodTile(
                selectedCountryKey: s.selectedCountry,
                selectedMethod: s.calculationMethod,
                isCalculatedLocation: s.isCalculatedLocation,
                onMethodSaved: sp.updateCalculationMethod,
              ),
              const SizedBox(height: 10),
              MobileSettingsTile(
                title: l.settingsMadhabLabel,
                subtitle: s.madhab == 'hanafi'
                    ? l.madhabHanafi
                    : l.madhabShafiFamily,
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => MobileMadhabDialog(
                    currentMadhab: s.madhab,
                    onSave: sp.updateMadhab,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MobileSettingsTile(
                title: l.settingsAdjustPrayerTimes,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MobilePrayerOffsetsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              MobileSettingsAppearanceSection(settingsProvider: sp),
              const SizedBox(height: 24),
              MobileSettingsSectionTitle(
                title: l.feedbackSection,
                icon: Icons.mark_chat_read_rounded,
              ),
              MobileSettingsTile(
                title: l.feedbackSettingsTile,
                onTap: () => Navigator.pushNamed(context, '/feedback'),
              ),
              const SizedBox(height: 24),
              MobileSettingsSectionTitle(
                title: l.settingsOther,
                icon: Icons.more_horiz,
              ),
              MobileSettingsTile(
                title: l.settingsPrivacyPolicy,
                onTap: () => PlatformLauncher.openUrl(AppConfig.privacyPolicyUrl),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
