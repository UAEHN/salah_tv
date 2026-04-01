import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_switch_row.dart';

class DarkModeSection extends StatelessWidget {
  const DarkModeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return TvSwitchRow(
      value: settings.isDarkMode,
      accent: palette.primary,
      onChanged: (v) => settingsProv.updateDarkMode(v),
      children: [
        Icon(
          settings.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
          color: settings.isDarkMode
              ? const Color(0xFF6A7494)
              : const Color(0xFFF59E0B),
          size: 26,
        ),
        const SizedBox(width: 12),
        Text(
          '${l.settingsDarkModeLabel}:',
          style: TextStyle(fontSize: 20, color: tc.textPrimary),
        ),
        const SizedBox(width: 16),
        Switch(
          value: settings.isDarkMode,
          activeTrackColor: const Color(0xFF162035),
          activeThumbColor: const Color(0xFFB8C0D8),
          inactiveTrackColor: kTextMuted.withValues(alpha: 0.3),
          thumbColor: WidgetStateProperty.all(Colors.white),
          onChanged: (v) => settingsProv.updateDarkMode(v),
        ),
        const SizedBox(width: 12),
        Text(
          settings.isDarkMode ? l.commonEnabled : l.commonDisabled,
          style: TextStyle(
            fontSize: 20,
            color: settings.isDarkMode ? kDarkTextSecondary : kTextMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
