import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_format_button.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;
    final palette = getThemePalette(settings.themeColorKey);

    return Row(
      children: [
        TvFormatButton(
          label: l.languageArabic,
          isSelected: settings.locale == 'ar',
          palette: palette,
          onPressed: () => settingsProvider.updateLocale('ar'),
        ),
        const SizedBox(width: 16),
        TvFormatButton(
          label: l.languageEnglish,
          isSelected: settings.locale == 'en',
          palette: palette,
          onPressed: () => settingsProvider.updateLocale('en'),
        ),
      ],
    );
  }
}
