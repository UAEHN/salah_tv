import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/calculation_method_info.dart';
import '../../../../../core/city_translations.dart';
import '../../screens/mobile_notification_settings_screen.dart';
import '../../screens/mobile_prayer_offsets_screen.dart';
import '../../settings_provider.dart';
import 'mobile_calculation_method_dialog.dart';
import 'mobile_location_dialog.dart';
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
                    '${cityLabel(s.selectedCity, locale: l.localeName)}${l.localeComma} ${countryLabel(s.selectedCountry, locale: l.localeName)}',
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => MobileLocationDialog(
                    currentCountry: s.selectedCountry,
                    currentCity: s.selectedCity,
                    onSave: sp.updateLocation,
                    onSaveWorld: sp.updateWorldLocation,
                  ),
                ),
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
              MobileSettingsTile(
                title: l.settingsCalculationMethodLabel,
                subtitle: localizedCalculationMethod(context, s.calculationMethod),
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => MobileCalculationMethodDialog(
                    currentMethod: s.calculationMethod,
                    onSave: sp.updateCalculationMethod,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MobileSettingsTile(
                title: l.settingsMadhabLabel,
                subtitle:
                    s.madhab == 'hanafi' ? l.madhabHanafi : l.madhabShafiFamily,
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
            ],
          ),
        ),
      ],
    );
  }
}
