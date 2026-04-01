import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_color_chip.dart';
import 'tv_font_chip.dart';
import 'tv_format_button.dart';

class FontSection extends StatelessWidget {
  const FontSection({super.key});

  static const _fontsArabic = ['Cairo', 'Beiruti', 'Kufi', 'Rubik'];
  static const _fontsEnglish = ['Cairo', 'Beiruti', 'Inter'];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final fonts = l.localeName == 'en' ? _fontsEnglish : _fontsArabic;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: fonts.map((fontKey) {
        return TvFontChip(
          fontKey: fontKey,
          label: _localizedFontLabel(l, fontKey),
          isSelected: settings.fontFamily == fontKey,
          palette: palette,
          onPressed: () => settingsProv.updateFontFamily(fontKey),
        );
      }).toList(),
    );
  }

  String _localizedFontLabel(AppLocalizations l, String fontKey) {
    switch (fontKey) {
      case 'Cairo':
        return l.fontCairo;
      case 'Beiruti':
        return l.fontBeiruti;
      case 'Kufi':
        return l.fontKufi;
      case 'Rubik':
        return l.fontRubik;
      case 'Inter':
        return l.fontInter;
      default:
        return fontKey;
    }
  }
}

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: kThemePalettes.entries.map((entry) {
        return TvColorChip(
          palette: entry.value,
          label: _localizedThemeLabel(l, entry.key),
          isSelected: settings.themeColorKey == entry.key,
          onPressed: () => settingsProv.updateTheme(entry.key),
        );
      }).toList(),
    );
  }

  String _localizedThemeLabel(AppLocalizations l, String themeKey) {
    switch (themeKey) {
      case 'green':
        return l.themeGreen;
      case 'teal':
        return l.themeTeal;
      case 'gold':
        return l.themeGold;
      case 'blue':
        return l.themeBlue;
      case 'purple':
        return l.themePurple;
      default:
        return themeKey;
    }
  }
}

class TimeFormatSection extends StatelessWidget {
  const TimeFormatSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);

    return Row(
      children: [
        TvFormatButton(
          label: l.settings24HourLabel,
          isSelected: settings.use24HourFormat,
          palette: palette,
          onPressed: () => settingsProv.updateTimeFormat(true),
        ),
        const SizedBox(width: 16),
        TvFormatButton(
          label: l.settings12HourLabel,
          isSelected: !settings.use24HourFormat,
          palette: palette,
          onPressed: () => settingsProv.updateTimeFormat(false),
        ),
      ],
    );
  }
}

class LayoutStyleSection extends StatelessWidget {
  const LayoutStyleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);

    return Row(
      children: [
        TvFormatButton(
          label: l.layoutModern,
          isSelected: settings.layoutStyle == 'modern',
          palette: palette,
          onPressed: () => settingsProv.updateLayoutStyle('modern'),
        ),
        const SizedBox(width: 16),
        TvFormatButton(
          label: l.layoutClassic,
          isSelected: settings.layoutStyle == 'classic',
          palette: palette,
          onPressed: () => settingsProv.updateLayoutStyle('classic'),
        ),
      ],
    );
  }
}

class ClockStyleSection extends StatelessWidget {
  const ClockStyleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);

    return Row(
      children: [
        TvFormatButton(
          label: l.clockDigital,
          isSelected: !settings.isAnalogClock,
          palette: palette,
          onPressed: () => settingsProv.updateClockStyle(isAnalog: false),
        ),
        const SizedBox(width: 16),
        TvFormatButton(
          label: l.clockAnalog,
          isSelected: settings.isAnalogClock,
          palette: palette,
          onPressed: () => settingsProv.updateClockStyle(isAnalog: true),
        ),
      ],
    );
  }
}
