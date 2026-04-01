import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/prayer_bloc.dart';
import 'prayer_card.dart';

class PrayerCardStrip extends StatelessWidget {
  const PrayerCardStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = context.select((PrayerBloc b) => b.state.todayPrayers);

    // During adhan -> dua -> iqama countdown -> iqama, keep the active prayer
    // highlighted instead of jumping to the next one.
    final nextKey = context.select((PrayerBloc b) {
      final cycle = b.state.activeCyclePrayerKey;
      return cycle.isNotEmpty ? cycle : b.state.nextPrayerKey;
    });

    final isPreAlert = context.select((PrayerBloc b) => b.state.isPrePrayerAlert);
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenW = MediaQuery.of(context).size.width;

    if (today == null) {
      return Center(
        child: Text(
          l.noPrayerDataToday,
          style: TextStyle(fontSize: 18, color: tc.textSecondary),
        ),
      );
    }

    final prayers = today.prayers.reversed.toList();
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
