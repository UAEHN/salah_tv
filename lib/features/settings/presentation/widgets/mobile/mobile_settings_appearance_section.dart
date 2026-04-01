import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../settings_provider.dart';
import 'mobile_language_dialog.dart';
import 'mobile_settings_section_title.dart';
import 'mobile_settings_tile.dart';
import 'mobile_theme_dialog.dart';
import 'mobile_time_format_dialog.dart';

/// Time format + appearance + other sections of the settings list.
class MobileSettingsAppearanceSection extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const MobileSettingsAppearanceSection({
    super.key,
    required this.settingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    final settings = settingsProvider.settings;
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MobileSettingsSectionTitle(
          title: l.settingsTimeFormat,
          icon: Icons.schedule,
        ),
        MobileSettingsTile(
          title: l.settings24HourFormat,
          subtitle: settings.use24HourFormat
              ? l.settings24HourEnabled
              : l.settings12HourEnabled,
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => MobileTimeFormatDialog(
              is24Hour: settings.use24HourFormat,
              onSave: settingsProvider.updateTimeFormat,
            ),
          ),
        ),
        const SizedBox(height: 24),
        MobileSettingsSectionTitle(
          title: l.settingsAppearance,
          icon: Icons.palette,
        ),
        MobileSettingsTile(
          title: l.settingsCustomizeAppearance,
          subtitle: settings.isDarkMode
              ? l.settingsDarkMode
              : l.settingsLightMode,
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => MobileThemeDialog(
              isDarkMode: settings.isDarkMode,
              onSave: settingsProvider.updateDarkMode,
            ),
          ),
        ),
        const SizedBox(height: 10),
        MobileSettingsTile(
          title: l.settingsLanguage,
          subtitle: settings.locale == 'ar'
              ? l.languageArabic
              : l.languageEnglish,
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => MobileLanguageDialog(
              currentLocale: settings.locale,
              onSave: settingsProvider.updateLocale,
            ),
          ),
        ),
        const SizedBox(height: 24),
        MobileSettingsSectionTitle(
          title: l.settingsOther,
          icon: Icons.more_horiz,
        ),
        MobileSettingsTile(title: l.settingsPrivacyPolicy, onTap: () {}),
      ],
    );
  }
}
