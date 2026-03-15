import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_small_button.dart';

class IqamaTable extends StatelessWidget {
  const IqamaTable({super.key});

  static const _prayers = [
    ('fajr', 'الفجر'),
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
    final delays = settingsProv.settings.iqamaDelays;

    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      decoration: tc.glass(opacity: 0.06, borderRadius: 14),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: _prayers.indexed.map((entry) {
          final i = entry.$1;
          final p = entry.$2;
          final key = p.$1;
          final name = p.$2;
          final delay = delays[key] ?? 10;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: tc.textMuted.withValues(alpha: 0.12),
                ),
              _DelayRow(
                name: name,
                delay: delay,
                palette: palette,
                tc: tc,
                onDecrement: () =>
                    settingsProv.updateIqamaDelay(key, delay - 1),
                onIncrement: () =>
                    settingsProv.updateIqamaDelay(key, delay + 1),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _DelayRow extends StatelessWidget {
  const _DelayRow({
    required this.name,
    required this.delay,
    required this.palette,
    required this.tc,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String name;
  final int delay;
  final AccentPalette palette;
  final ThemeColors tc;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          TvSmallButton(
            icon: Icons.remove,
            palette: palette,
            onPressed: onDecrement,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 48,
            child: Text(
              '$delay',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: palette.primary,
                shadows: [Shadow(color: palette.glow, blurRadius: 8)],
              ),
            ),
          ),
          const SizedBox(width: 10),
          TvSmallButton(
            icon: Icons.add,
            palette: palette,
            onPressed: onIncrement,
          ),
          const SizedBox(width: 16),
          Text(
            'دقيقة',
            style: TextStyle(fontSize: 12, color: tc.textMuted),
          ),
          const Spacer(),
          Text(
            name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: tc.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
