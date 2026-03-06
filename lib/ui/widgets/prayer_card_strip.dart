import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';
import 'prayer_card.dart';

class PrayerCardStrip extends StatelessWidget {
  const PrayerCardStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerProv = context.watch<PrayerProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final today = prayerProv.todayPrayers;
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
    final nextKey = prayerProv.nextPrayerKey;
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
