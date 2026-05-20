import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/adhan_sounds.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/localization/adhan_sound_localizer.dart';
import '../../domain/entities/prayer_sound_mode.dart';
import '../dialogs/adhan_sound_picker_dialog.dart';
import '../settings_provider.dart';
import 'section_title.dart';
import 'sound_mode_picker.dart';
import '../../../../core/widgets/tv_button.dart';

class AdhanSection extends StatelessWidget {
  const AdhanSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final adhanHasSound = settings.adhanMode == PrayerSoundMode.sound;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (adhanHasSound) ...[
          SettingsSectionTitle(title: l.settingsAdhanSoundLabel),
          const SizedBox(height: 12),
          _AdhanSoundPicker(
            palette: palette,
            tc: tc,
            settings: settings,
            settingsProv: settingsProv,
            l: l,
          ),
          const SizedBox(height: 24),
        ],
        SettingsSectionTitle(title: l.adhanLabel),
        const SizedBox(height: 12),
        SoundModePicker(
          value: settings.adhanMode,
          onChanged: settingsProv.updateAdhanMode,
          palette: palette,
          tc: tc,
        ),
        const SizedBox(height: 24),
        SettingsSectionTitle(title: l.iqamaLabel),
        const SizedBox(height: 12),
        SoundModePicker(
          value: settings.iqamaMode,
          onChanged: settingsProv.updateIqamaMode,
          palette: palette,
          tc: tc,
        ),
      ],
    );
  }
}

class _AdhanSoundPicker extends StatelessWidget {
  final AccentPalette palette;
  final ThemeColors tc;
  final dynamic settings;
  final SettingsProvider settingsProv;
  final AppLocalizations l;

  const _AdhanSoundPicker({
    required this.palette,
    required this.tc,
    required this.settings,
    required this.settingsProv,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: tc.glass(opacity: 0.06, borderRadius: 10),
            child: Row(
              children: [
                Icon(Icons.volume_up_rounded, color: palette.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizedAdhanSoundLabel(
                      context,
                      kAdhanSounds
                          .firstWhere(
                            (s) => s.key == settings.adhanSound,
                            orElse: () => kAdhanSounds.first,
                          )
                          .key,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      color: tc.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        TvButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => AdhanSoundPickerDialog(
              palette: palette,
              selectedKey: settings.adhanSound,
              onSelected: settingsProv.updateAdhanSound,
            ),
          ),
          accent: palette.primary,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                l.settingsChangeAdhan,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
