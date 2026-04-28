import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../quran/domain/entities/quran_playback_mode.dart';
import '../settings_provider.dart';
import 'quran_continuous_controls.dart';
import 'quran_playlist_controls.dart';
import 'quran_single_surah_controls.dart';
import 'tv_focusable_card.dart';

/// Three-mode picker (continuous / single surah / playlist) + nested controls.
class QuranPlaybackModeSection extends StatelessWidget {
  const QuranPlaybackModeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          l.settingsQuranPlaybackMode,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: tc.textPrimary),
        ),
        const SizedBox(height: 10),
        _ModeChoice(
          mode: QuranPlaybackMode.continuous,
          icon: Icons.all_inclusive_rounded,
          title: l.settingsQuranModeContinuous,
          subtitle: l.settingsQuranModeContinuousDesc,
          palette: palette,
          tc: tc,
        ),
        const SizedBox(height: 8),
        _ModeChoice(
          mode: QuranPlaybackMode.singleSurah,
          icon: Icons.bookmark_rounded,
          title: l.settingsQuranModeSingleSurah,
          subtitle: l.settingsQuranModeSingleSurahDesc,
          palette: palette,
          tc: tc,
        ),
        const SizedBox(height: 8),
        _ModeChoice(
          mode: QuranPlaybackMode.playlist,
          icon: Icons.playlist_play_rounded,
          title: l.settingsQuranModePlaylist,
          subtitle: l.settingsQuranModePlaylistDesc,
          palette: palette,
          tc: tc,
        ),
        if (settings.quranPlaybackMode == QuranPlaybackMode.continuous) ...[
          const SizedBox(height: 14),
          const QuranContinuousControls(),
        ],
        if (settings.quranPlaybackMode == QuranPlaybackMode.singleSurah) ...[
          const SizedBox(height: 14),
          const QuranSingleSurahControls(),
        ],
        if (settings.quranPlaybackMode == QuranPlaybackMode.playlist) ...[
          const SizedBox(height: 14),
          const QuranPlaylistControls(),
        ],
      ],
    );
  }
}

class _ModeChoice extends StatelessWidget {
  final QuranPlaybackMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final AccentPalette palette;
  final ThemeColors tc;

  const _ModeChoice({
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
    final isSelected = prov.settings.quranPlaybackMode == mode;
    return TvFocusableCard(
      onPressed: () => prov.updateQuranPlaybackMode(mode),
      accent: palette.primary,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
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
                color: isSelected ? palette.primary : tc.textMuted, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: tc.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 14, color: tc.textMuted)),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? palette.primary : tc.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
