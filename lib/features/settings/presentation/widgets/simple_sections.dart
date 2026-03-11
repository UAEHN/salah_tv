import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_color_chip.dart';
import 'tv_font_chip.dart';
import 'tv_format_button.dart';

class FontSection extends StatelessWidget {
  const FontSection({super.key});

  static const _fonts = [
    ('Cairo', 'كايرو'),
    ('Beiruti', 'بيروتي'),
    ('Kufi', 'كوفي'),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: _fonts.map((f) {
        return TvFontChip(
          fontKey: f.$1,
          label: f.$2,
          isSelected: settings.fontFamily == f.$1,
          palette: palette,
          onPressed: () => settingsProv.updateFontFamily(f.$1),
        );
      }).toList(),
    );
  }
}

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: kThemePalettes.entries.map((e) {
        return TvColorChip(
          palette: e.value,
          label: kThemeLabels[e.key] ?? e.key,
          isSelected: settings.themeColorKey == e.key,
          onPressed: () => settingsProv.updateTheme(e.key),
        );
      }).toList(),
    );
  }
}

class TimeFormatSection extends StatelessWidget {
  const TimeFormatSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    return Row(
      children: [
        TvFormatButton(
          label: '24 ساعة',
          isSelected: settings.use24HourFormat,
          palette: palette,
          onPressed: () => settingsProv.updateTimeFormat(true),
        ),
        const SizedBox(width: 16),
        TvFormatButton(
          label: '12 ساعة',
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
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    return Row(
      children: [
        TvFormatButton(
          label: 'حديث',
          isSelected: settings.layoutStyle == 'modern',
          palette: palette,
          onPressed: () => settingsProv.updateLayoutStyle('modern'),
        ),
        const SizedBox(width: 16),
        TvFormatButton(
          label: 'كلاسيكي',
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
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    return Row(
      children: [
        TvFormatButton(
          label: 'رقمي',
          isSelected: !settings.isAnalogClock,
          palette: palette,
          onPressed: () => settingsProv.updateClockStyle(isAnalog: false),
        ),
        const SizedBox(width: 16),
        TvFormatButton(
          label: 'تناظري',
          isSelected: settings.isAnalogClock,
          palette: palette,
          onPressed: () => settingsProv.updateClockStyle(isAnalog: true),
        ),
      ],
    );
  }
}
