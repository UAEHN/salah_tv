import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/adhan_sounds.dart';
import '../settings_provider.dart';
import '../dialogs/adhan_sound_picker_dialog.dart';
import 'section_title.dart';
import 'tv_button.dart';
import 'tv_switch_row.dart';

class AdhanSection extends StatelessWidget {
  const AdhanSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TvSwitchRow(
          value: settings.playAdhan,
          accent: palette.primary,
          onChanged: (v) => settingsProv.updatePlayAdhan(v),
          children: [
            Text(
              'تشغيل الأذان تلقائياً:',
              style: TextStyle(fontSize: 20, color: tc.textPrimary),
            ),
            const SizedBox(width: 16),
            Switch(
              value: settings.playAdhan,
              activeTrackColor: palette.primary,
              inactiveTrackColor: tc.textMuted.withValues(alpha: 0.3),
              thumbColor: WidgetStateProperty.all(Colors.white),
              onChanged: (v) => settingsProv.updatePlayAdhan(v),
            ),
            const SizedBox(width: 12),
            Text(
              settings.playAdhan ? 'مفعّل' : 'معطّل',
              style: TextStyle(
                fontSize: 20,
                color: settings.playAdhan ? palette.primary : tc.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (settings.playAdhan) ...[
          const SizedBox(height: 16),
          SettingsSectionTitle(title: 'صوت الأذان'),
          const SizedBox(height: 12),
          Row(
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
                          kAdhanSounds
                              .firstWhere(
                                (s) => s.key == settings.adhanSound,
                                orElse: () => kAdhanSounds.first,
                              )
                              .label,
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
                    onSelected: (key) => settingsProv.updateAdhanSound(key),
                  ),
                ),
                accent: palette.primary,
                filled: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('تغيير الأذان', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
