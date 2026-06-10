import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../domain/entities/prayer_sound_mode.dart';
import 'tv_focusable_card.dart';

/// Three-segment selector for [PrayerSoundMode] (sound / silent / off).
/// Shared between the adhan and iqama settings rows.
class SoundModePicker extends StatelessWidget {
  final PrayerSoundMode value;
  final ValueChanged<PrayerSoundMode> onChanged;
  final AccentPalette palette;
  final ThemeColors tc;

  const SoundModePicker({
    required this.value,
    required this.onChanged,
    required this.palette,
    required this.tc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        _ModeChoice(
          mode: PrayerSoundMode.sound,
          icon: Icons.volume_up_rounded,
          title: l.settingsSoundModeSound,
          subtitle: l.settingsSoundModeSoundDesc,
          value: value,
          onChanged: onChanged,
          palette: palette,
          tc: tc,
        ),
        const SizedBox(height: 6),
        _ModeChoice(
          mode: PrayerSoundMode.silent,
          icon: Icons.volume_off_rounded,
          title: l.settingsSoundModeSilent,
          subtitle: l.settingsSoundModeSilentDesc,
          value: value,
          onChanged: onChanged,
          palette: palette,
          tc: tc,
        ),
        const SizedBox(height: 6),
        _ModeChoice(
          mode: PrayerSoundMode.off,
          icon: Icons.do_not_disturb_on_outlined,
          title: l.settingsSoundModeOff,
          subtitle: l.settingsSoundModeOffDesc,
          value: value,
          onChanged: onChanged,
          palette: palette,
          tc: tc,
        ),
      ],
    );
  }
}

class _ModeChoice extends StatelessWidget {
  final PrayerSoundMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final PrayerSoundMode value;
  final ValueChanged<PrayerSoundMode> onChanged;
  final AccentPalette palette;
  final ThemeColors tc;

  const _ModeChoice({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.palette,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == mode;
    return TvFocusableCard(
      onPressed: () => onChanged(mode),
      accent: palette.primary,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.primary.withValues(alpha: 0.12)
              : tc.glass(opacity: 0.05).color,
          border: Border.all(
            color: isSelected
                ? palette.primary
                : palette.primary.withValues(alpha: 0.18),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? palette.primary : tc.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: tc.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: tc.textSecondary,
                      height: 1.35,
                    ),
                  ),
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
