import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/city_translations.dart';
import '../../screens/mobile_notification_settings_screen.dart';
import '../../settings_provider.dart';
import 'mobile_settings_tile.dart';
import 'mobile_theme_dialog.dart';
import 'mobile_time_format_dialog.dart';
import 'mobile_location_dialog.dart';
import 'mobile_settings_header.dart';
import 'mobile_settings_section_title.dart';

class MobileSettingsList extends StatelessWidget {
  const MobileSettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Column(
      children: [
        const MobileSettingsHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
            physics: const BouncingScrollPhysics(),
            children: [
              const MobileSettingsSectionTitle(
                title: 'الموقع',
                icon: Icons.location_on,
              ),
              MobileSettingsTile(
                title: 'الدولة والمدينة',
                subtitle:
                    '${cityLabel(settings.selectedCity)}، ${countryLabel(settings.selectedCountry)}',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => MobileLocationDialog(
                      currentCountry: settings.selectedCountry,
                      currentCity: settings.selectedCity,
                      onSave: (country, city) async {
                        await settingsProvider.updateLocation(country, city);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const MobileSettingsSectionTitle(
                title: 'التنبيهات',
                icon: Icons.notifications_active,
              ),
              MobileSettingsTile(
                title: 'إعدادات التنبيهات',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MobileNotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const MobileSettingsSectionTitle(
                title: 'صيغة الوقت',
                icon: Icons.schedule,
              ),
              MobileSettingsTile(
                title: 'صيغة 24 ساعة',
                subtitle: settings.use24HourFormat
                    ? 'نظام 24 ساعة'
                    : 'نظام 12 ساعة',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => MobileTimeFormatDialog(
                      is24Hour: settings.use24HourFormat,
                      onSave: (is24h) {
                        settingsProvider.updateTimeFormat(is24h);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const MobileSettingsSectionTitle(
                title: 'المظهر',
                icon: Icons.palette,
              ),
              MobileSettingsTile(
                title: 'تخصيص المظهر',
                subtitle: settings.isDarkMode ? 'الوضع الداكن' : 'الوضع الفاتح',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => MobileThemeDialog(
                      isDarkMode: settings.isDarkMode,
                      onSave: (isDark) {
                        settingsProvider.updateDarkMode(isDark);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const MobileSettingsSectionTitle(
                title: 'أخرى',
                icon: Icons.more_horiz,
              ),
              MobileSettingsTile(title: 'سياسة الخصوصية', onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
