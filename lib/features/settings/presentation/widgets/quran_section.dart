import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'quran_playback_mode_section.dart';
import 'quran_reciter_row.dart';
import 'tv_switch_row.dart';

class QuranSection extends StatelessWidget {
  const QuranSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TvSwitchRow(
          value: settings.isQuranEnabled,
          accent: palette.primary,
          onChanged: settingsProv.updateIsQuranEnabled,
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: settings.isQuranEnabled ? palette.primary : tc.textMuted,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              l.settingsQuranInBackground,
              style: TextStyle(fontSize: 20, color: tc.textPrimary),
            ),
            const SizedBox(width: 16),
            Switch(
              value: settings.isQuranEnabled,
              activeTrackColor: palette.primary,
              inactiveTrackColor: tc.textMuted.withValues(alpha: 0.3),
              thumbColor: WidgetStateProperty.all(Colors.white),
              onChanged: settingsProv.updateIsQuranEnabled,
            ),
            const SizedBox(width: 12),
            Text(
              settings.isQuranEnabled ? l.commonEnabled : l.commonDisabled,
              style: TextStyle(
                fontSize: 20,
                color: settings.isQuranEnabled ? palette.primary : tc.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (settings.isQuranEnabled) ...[
          const SizedBox(height: 16),
          const QuranReciterRow(),
          const QuranPlaybackModeSection(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: tc.glass(opacity: 0.05, borderRadius: 10),
            child: Row(
              children: [
                Icon(Icons.wifi_rounded, color: tc.textMuted, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.settingsInternetRequiredForQuran,
                    style: TextStyle(fontSize: 14, color: tc.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
