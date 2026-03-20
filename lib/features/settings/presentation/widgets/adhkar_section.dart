import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';
import 'tv_switch_row.dart';

class AdhkarSection extends StatelessWidget {
  const AdhkarSection({super.key});

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
          value: settings.isAdhkarEnabled,
          accent: palette.primary,
          onChanged: (v) => settingsProv.updateIsAdhkarEnabled(v),
          children: [
            Icon(
              Icons.auto_stories_rounded,
              color: settings.isAdhkarEnabled ? palette.primary : tc.textMuted,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              'أذكار الصباح والمساء:',
              style: TextStyle(fontSize: 20, color: tc.textPrimary),
            ),
            const SizedBox(width: 16),
            Switch(
              value: settings.isAdhkarEnabled,
              activeTrackColor: palette.primary,
              inactiveTrackColor: kTextMuted.withValues(alpha: 0.3),
              thumbColor: WidgetStateProperty.all(Colors.white),
              onChanged: (v) => settingsProv.updateIsAdhkarEnabled(v),
            ),
            const SizedBox(width: 12),
            Text(
              settings.isAdhkarEnabled ? 'مفعّل' : 'معطّل',
              style: TextStyle(
                fontSize: 20,
                color: settings.isAdhkarEnabled ? palette.primary : tc.textMuted,
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
                  'تُعرض الأذكار تلقائياً بين الفجر والظهر، وبين العصر والعشاء. تختفي قبل الأذان بدقيقتين.',
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
