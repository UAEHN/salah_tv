import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_switch_row.dart';

/// Settings block for the «أذكار بعد الصلاة» takeover: an enable toggle and a
/// short explanatory note. Independent of the morning/evening adhkar toggle.
class AfterPrayerAdhkarSection extends StatelessWidget {
  const AfterPrayerAdhkarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final isOn = settings.isAfterPrayerAdhkarEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TvSwitchRow(
          value: isOn,
          accent: palette.primary,
          onChanged: settingsProv.updateIsAfterPrayerAdhkarEnabled,
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: isOn ? palette.primary : tc.textMuted,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              l.adhkarAfterPrayerTitle,
              style: TextStyle(fontSize: 20, color: tc.textPrimary),
            ),
            const SizedBox(width: 16),
            Switch(
              value: isOn,
              activeTrackColor: palette.primary,
              inactiveTrackColor: kTextMuted.withValues(alpha: 0.3),
              thumbColor: WidgetStateProperty.all(Colors.white),
              onChanged: settingsProv.updateIsAfterPrayerAdhkarEnabled,
            ),
            const SizedBox(width: 12),
            Text(
              isOn ? l.commonEnabled : l.commonDisabled,
              style: TextStyle(
                fontSize: 20,
                color: isOn ? palette.primary : tc.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tc.textMuted.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: tc.textMuted, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.settingsAfterPrayerAdhkarNote,
                  style: TextStyle(fontSize: 14, color: tc.textMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
