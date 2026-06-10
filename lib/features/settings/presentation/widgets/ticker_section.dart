import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_switch_row.dart';

class TickerSection extends StatelessWidget {
  const TickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return TvSwitchRow(
      value: settings.isTickerEnabled,
      accent: palette.primary,
      onChanged: (v) => settingsProv.updateIsTickerEnabled(v),
      children: [
        Icon(
          Icons.view_carousel_rounded,
          color: settings.isTickerEnabled ? palette.primary : tc.textMuted,
          size: 26,
        ),
        const SizedBox(width: 12),
        Text(
          l.settingsTickerLabel,
          style: TextStyle(fontSize: 20, color: tc.textPrimary),
        ),
        const SizedBox(width: 16),
        Switch(
          value: settings.isTickerEnabled,
          activeTrackColor: palette.primary,
          inactiveTrackColor: kTextMuted.withValues(alpha: 0.3),
          thumbColor: WidgetStateProperty.all(Colors.white),
          onChanged: (v) => settingsProv.updateIsTickerEnabled(v),
        ),
        const SizedBox(width: 12),
        Text(
          settings.isTickerEnabled ? l.commonEnabled : l.commonDisabled,
          style: TextStyle(
            fontSize: 20,
            color: settings.isTickerEnabled ? palette.primary : tc.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
