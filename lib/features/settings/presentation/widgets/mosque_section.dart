import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'section_title.dart';
import 'tv_switch_row.dart';

/// Mosque-mode toggle. Forces silent visual takeover (the muezzin handles
/// audio live), shows a 2.5-minute "حان وقت الصلاة" pulsing screen at adhan
/// time, and a "استووا للصلاة" call during the last minute of the iqama
/// countdown. Engine reads [AppSettings.isMosqueMode] to apply overrides.
class MosqueSection extends StatelessWidget {
  const MosqueSection({super.key});

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
        SettingsSectionTitle(title: l.settingsCategoryMosque),
        const SizedBox(height: 12),
        TvSwitchRow(
          value: settings.isMosqueMode,
          accent: palette.primary,
          onChanged: settingsProv.updateIsMosqueMode,
          children: [
            Icon(Icons.mosque_rounded,
                color: settings.isMosqueMode
                    ? palette.primary
                    : tc.textMuted,
                size: 26),
            const SizedBox(width: 12),
            Text(
              l.settingsMosqueMode,
              style: TextStyle(fontSize: 20, color: tc.textPrimary),
            ),
            const SizedBox(width: 16),
            Switch(
              value: settings.isMosqueMode,
              activeTrackColor: palette.primary,
              inactiveTrackColor: tc.textMuted.withValues(alpha: 0.3),
              thumbColor: WidgetStateProperty.all(Colors.white),
              onChanged: settingsProv.updateIsMosqueMode,
            ),
            const SizedBox(width: 12),
            Text(
              settings.isMosqueMode ? l.commonEnabled : l.commonDisabled,
              style: TextStyle(
                fontSize: 20,
                color: settings.isMosqueMode
                    ? palette.primary
                    : tc.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: tc.glass(opacity: 0.05, borderRadius: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  color: palette.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.settingsMosqueModeDesc,
                  style: TextStyle(
                    fontSize: 15,
                    color: tc.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
