import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_list_item_mapper.dart';
import '../bloc/prayer_ui_logic.dart';
import 'prayer_card.dart';

class PrayerCardStrip extends StatelessWidget {
  const PrayerCardStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = context.select((PrayerBloc b) => b.state.todayPrayers);

    // During adhan -> dua -> iqama countdown -> iqama, keep the active prayer
    // highlighted instead of jumping to the next one.
    final nextKey = context.select(
      (PrayerBloc b) => effectiveActivePrayerKey(
        activeCyclePrayerKey: b.state.activeCyclePrayerKey,
        nextPrayerKey: b.state.nextPrayerKey,
      ),
    );

    final isPreAlert = context.select(
      (PrayerBloc b) => b.state.isPrePrayerAlert,
    );
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

    final items = mapPrayerCardStripItems(
      today: today,
      activePrayerKey: nextKey,
      isPrePrayerAlert: isPreAlert,
      settings: settings,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenW * 0.025),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i < items.length - 1 ? screenW * 0.006 : 0,
                right: i > 0 ? screenW * 0.006 : 0,
              ),
              child: PrayerCard(
                prayer: item.prayer,
                isNext: item.isNext,
                isPassed: item.isPassed,
                isPreAlert: item.isPreAlert,
                settings: settings,
                iqamaDelay: item.iqamaDelay,
                adhanOffset: item.adhanOffset,
              ),
            ),
          );
        }),
      ),
    );
  }
}
