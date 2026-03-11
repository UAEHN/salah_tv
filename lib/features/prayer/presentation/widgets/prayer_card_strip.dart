import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../models/daily_prayer_times.dart';
import '../prayer_provider.dart';
import '../../../settings/presentation/settings_provider.dart';
import 'prayer_card.dart';

class PrayerCardStrip extends StatelessWidget {
  const PrayerCardStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final today = context.select<PrayerProvider, DailyPrayerTimes?>(
      (p) => p.todayPrayers,
    );
    // During adhan → dua → iqama countdown → iqama, keep the active prayer
    // highlighted instead of jumping to the next one.
    final nextKey = context.select<PrayerProvider, String>((p) {
      final cycle = p.activeCyclePrayerKey;
      return cycle.isNotEmpty ? cycle : p.nextPrayerKey;
    });
    final isPreAlert = context.select<PrayerProvider, bool>(
      (p) => p.isPrePrayerAlert,
    );
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenW = MediaQuery.of(context).size.width;

    if (today == null) {
      return Center(
        child: Text(
          'لا توجد بيانات لهذا اليوم',
          style: TextStyle(fontSize: 18, color: tc.textSecondary),
        ),
      );
    }

    final prayers = today.prayers.reversed.toList();
    // Determine prayer order for "passed" logic
    const prayerOrder = [
      'fajr',
      'sunrise',
      'dhuhr',
      'asr',
      'maghrib',
      'isha',
    ];
    final nextIndex = prayerOrder.indexOf(nextKey);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.025),
      child: Row(
        children: List.generate(prayers.length, (i) {
          final p = prayers[i];
          final isNext = p.key == nextKey;
          final pIndex = prayerOrder.indexOf(p.key);
          // A prayer is "passed" if its index is before the next prayer
          // Special case: if nextKey is fajr (all passed = next day)
          final isPassed = nextIndex >= 0 && pIndex < nextIndex;
          final delay = settings.iqamaDelays[p.key] ?? 10;
          final offset = settings.adhanOffsets[p.key] ?? 0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i < prayers.length - 1 ? screenW * 0.006 : 0,
                right: i > 0 ? screenW * 0.006 : 0,
              ),
              child: PrayerCard(
                prayer: p,
                isNext: isNext,
                isPassed: isPassed,
                isPreAlert: isNext && isPreAlert,
                settings: settings,
                iqamaDelay: delay,
                adhanOffset: offset,
              ),
            ),
          );
        }),
      ),
    );
  }
}
