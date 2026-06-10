import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../customization/presentation/logic/customization_l10n_resolver.dart';
import '../../settings_provider.dart';
import 'mobile_language_dialog.dart';
import 'mobile_settings_section_title.dart';
import 'mobile_settings_tile.dart';
import 'mobile_theme_dialog.dart';
import 'mobile_time_format_dialog.dart';

/// Time format + appearance sections of the settings list.
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
          icon: Icons.schedule_rounded,
        ),
        MobileSettingsTile(
          icon: Icons.access_time_rounded,
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
        const SizedBox(height: 22),
        MobileSettingsSectionTitle(
          title: l.settingsAppearance,
          icon: Icons.palette_rounded,
        ),
        MobileSettingsTile(
          icon: Icons.brightness_6_rounded,
          title: l.settingsCustomizeAppearance,
          subtitle: _themeModeLabel(l, settings.themeMode),
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => MobileThemeDialog(
              currentMode: settings.themeMode,
              onSave: settingsProvider.updateThemeMode,
            ),
          ),
        ),
        const SizedBox(height: 10),
        MobileSettingsTile(
          icon: Icons.color_lens_outlined,
          title: l.settingsThemePicker,
          subtitle: resolveThemeLabel(
            l,
            themeKeyToLabelKey(settings.themeColorKey),
          ),
          onTap: () => Navigator.of(context).pushNamed('/theme_picker'),
        ),
        const SizedBox(height: 10),
        MobileSettingsTile(
          icon: Icons.text_fields_rounded,
          title: l.settingsFontPicker,
          subtitle: resolveFontLabel(
            l,
            fontFamilyToLabelKey(settings.fontFamily),
          ),
          onTap: () => Navigator.of(context).pushNamed('/font_picker'),
        ),
        const SizedBox(height: 10),
        MobileSettingsTile(
          icon: Icons.translate_rounded,
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
      ],
    );
  }

  String _themeModeLabel(AppLocalizations l, String mode) => switch (mode) {
    'system' => l.settingsSystemMode,
    'dark' => l.settingsDarkMode,
    _ => l.settingsLightMode,
  };
}
