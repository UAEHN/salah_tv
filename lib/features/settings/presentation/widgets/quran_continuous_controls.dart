import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../quran/domain/entities/quran_playback_mode.dart';
import '../settings_provider.dart';
import 'tv_focusable_card.dart';

/// Controls visible when [QuranPlaybackMode.continuous] is active.
/// Three radio-style choices:
///   • fromStart → always begin at Al-Fatiha
///   • resume    → continue from the last surah heard (default)
///   • random    → start at a random surah, then random ordering
class QuranContinuousControls extends StatelessWidget {
  const QuranContinuousControls({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.settingsQuranContinuousStart,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: tc.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _StartChoice(
          mode: ContinuousStartMode.resume,
          icon: Icons.play_circle_outline_rounded,
          title: l.settingsQuranContinuousResume,
          subtitle: l.settingsQuranContinuousResumeDesc,
          palette: palette,
          tc: tc,
        ),
        const SizedBox(height: 6),
        _StartChoice(
          mode: ContinuousStartMode.fromStart,
          icon: Icons.first_page_rounded,
          title: l.settingsQuranContinuousFromStart,
          subtitle: l.settingsQuranContinuousFromStartDesc,
          palette: palette,
          tc: tc,
        ),
        const SizedBox(height: 6),
        _StartChoice(
          mode: ContinuousStartMode.random,
          icon: Icons.shuffle_rounded,
          title: l.settingsQuranContinuousRandom,
          subtitle: l.settingsQuranContinuousRandomDesc,
          palette: palette,
          tc: tc,
        ),
      ],
    );
  }
}

class _StartChoice extends StatelessWidget {
  final ContinuousStartMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final AccentPalette palette;
  final ThemeColors tc;

  const _StartChoice({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SettingsProvider>();
    final isSelected = prov.settings.continuousStartMode == mode;
    return TvFocusableCard(
      onPressed: () => prov.updateContinuousStartMode(mode),
      accent: palette.primary,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.primary.withValues(alpha: 0.12)
              : tc.glass(opacity: 0.05).color,
          border: Border.all(
            color: isSelected ? palette.primary : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? palette.primary : tc.textMuted, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: tc.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: tc.textMuted)),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? palette.primary : tc.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
