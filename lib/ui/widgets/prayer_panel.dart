import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/app_colors.dart';
import 'prayer_row.dart';

class PrayerPanel extends StatelessWidget {
  const PrayerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final prayer   = context.watch<PrayerProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final palette  = getThemePalette(settings.themeColorKey);
    final tc       = ThemeColors.of(settings.isDarkMode);
    final today    = prayer.todayPrayers;

    return Container(
      decoration: BoxDecoration(
        color: tc.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tc.borderGlass, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: settings.isDarkMode ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              gradient: palette.gradient,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mosque_rounded,
                    color: Colors.white.withValues(alpha: 0.9), size: 26),
                const SizedBox(width: 10),
                Text(
                  'مواقيت الصلاة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Prayer rows
          Expanded(
            child: today == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: palette.primary.withValues(alpha: 0.6),
                            size: 48),
                        const SizedBox(height: 12),
                        Text('لا توجد بيانات لهذا اليوم',
                          style: TextStyle(
                            fontSize: 18, color: tc.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text('تحقق من ملف CSV في الإعدادات',
                          style: TextStyle(
                            fontSize: 14, color: tc.textMuted),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: today.prayers.map((p) {
                      final delay = settings.iqamaDelays[p.key] ?? 10;
                      final offset = settings.adhanOffsets[p.key] ?? 0;
                      return Expanded(
                        child: PrayerRow(
                          prayer: p,
                          isNext: p.key == prayer.nextPrayerKey,
                          settings: settings,
                          iqamaDelay: delay,
                          adhanOffset: offset,
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
        ),
      ),
    );
  }
}
