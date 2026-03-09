import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_small_button.dart';

class AdhanOffsetsTable extends StatelessWidget {
  const AdhanOffsetsTable({super.key});

  static const _prayers = [
    ('fajr', 'الفجر'),
    ('sunrise', 'الشروق'),
    ('dhuhr', 'الظهر'),
    ('asr', 'العصر'),
    ('maghrib', 'المغرب'),
    ('isha', 'العشاء'),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final palette = getThemePalette(settingsProv.settings.themeColorKey);
    final tc = ThemeColors.of(settingsProv.settings.isDarkMode);
    final offsets = settingsProv.settings.adhanOffsets;
    return Wrap(
      spacing: 20,
      runSpacing: 16,
      children: _prayers.map((p) {
        final key = p.$1;
        final name = p.$2;
        final offset = offsets[key] ?? 0;
        return Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: tc.glass(opacity: 0.06, borderRadius: 14),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: tc.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TvSmallButton(
                    icon: Icons.remove,
                    palette: palette,
                    onPressed: () => settingsProv.updateAdhanOffset(key, offset - 1),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    child: Text(
                      offset >= 0 ? '+$offset' : '$offset',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: offset == 0 ? tc.textMuted : palette.primary,
                        shadows: offset != 0
                            ? [Shadow(color: palette.glow, blurRadius: 8)]
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TvSmallButton(
                    icon: Icons.add,
                    palette: palette,
                    onPressed: () => settingsProv.updateAdhanOffset(key, offset + 1),
                  ),
                ],
              ),
              Text('دقيقة', style: TextStyle(fontSize: 14, color: tc.textMuted)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
