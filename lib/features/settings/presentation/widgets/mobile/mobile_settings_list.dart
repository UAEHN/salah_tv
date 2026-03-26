import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/city_translations.dart';
import '../../../../../features/prayer/data/calculation_method_map.dart';
import '../../screens/mobile_notification_settings_screen.dart';
import '../../screens/mobile_prayer_offsets_screen.dart';
import '../../settings_provider.dart';
import 'mobile_calculation_method_dialog.dart';
import 'mobile_madhab_dialog.dart';
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
                      onSaveWorld: (country, city, lat, lng, method,
                          {double? utcOffsetHours}) async {
                        await settingsProvider.updateWorldLocation(
                          country, city, lat, lng, method,
                          utcOffsetHours: utcOffsetHours,
                        );
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
                title: 'الحساب',
                icon: Icons.calculate_rounded,
              ),
              MobileSettingsTile(
                title: 'طريقة الحساب',
                subtitle: kCalculationMethodLabels[settings.calculationMethod],
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => MobileCalculationMethodDialog(
                    currentMethod: settings.calculationMethod,
                    onSave: settingsProvider.updateCalculationMethod,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MobileSettingsTile(
                title: 'المذهب الفقهي',
                subtitle: settings.madhab == 'hanafi' ? 'الحنفي' : 'الشافعي / المالكي / الحنبلي',
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => MobileMadhabDialog(
                    currentMadhab: settings.madhab,
                    onSave: settingsProvider.updateMadhab,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MobileSettingsTile(
                title: 'تعديل أوقات الأذان والإقامة',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MobilePrayerOffsetsScreen(),
                  ),
                ),
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
