import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../settings/presentation/settings_provider.dart';
import '../../bloc/prayer_bloc.dart';
import '../../../../../core/mobile_theme.dart';
import 'mobile_prayer_row.dart';

class MobilePrayerList extends StatelessWidget {
  final bool is24HourFormat;

  const MobilePrayerList({super.key, required this.is24HourFormat});

  @override
  Widget build(BuildContext context) {
    final prayers = context.select(
      (PrayerBloc b) => b.state.displayedPrayers?.prayersOnly ?? const [],
    );
    final isViewingToday = context.select(
      (PrayerBloc b) => b.state.isViewingToday,
    );
    final isBusy = context.select(
      (PrayerBloc b) => b.state.isDateNavigationBusy,
    );
    final nextPrayerKey = context.select(
      (PrayerBloc b) => b.state.nextPrayerKey,
    );
    final activeCyclePrayerKey = context.select(
      (PrayerBloc b) => b.state.activeCyclePrayerKey,
    );
    final adhanOffsets = context.select(
      (SettingsProvider p) => p.settings.adhanOffsets,
    );
    // During iqama countdown/cycle, keep highlight on the active prayer,
    // not the next upcoming one.
    final activeKey = !isViewingToday
        ? ''
        : activeCyclePrayerKey.isNotEmpty
        ? activeCyclePrayerKey
        : nextPrayerKey;
    if (prayers.isEmpty) {
      return Center(
        child: isBusy
            ? const CircularProgressIndicator(
                color: MobileColors.primaryContainer,
                strokeWidth: 2,
              )
            : Text(
                'لا توجد بيانات لهذا التاريخ',
                style: MobileTextStyles.bodyMd(
                  context,
                ).copyWith(color: MobileColors.onSurfaceMuted(context)),
                textDirection: TextDirection.rtl,
              ),
      );
    }

    const spacing = 12.0;
    const hPad = 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the maximum allowed height per item based on available screen space
        // We subtract the total spacing from the max height and divide by number of prayers.
        // We do NOT clamp with a hardcoded bottom value (like 60.0) because on small screens
        // that will force the items to overflow the constrained height.
        final calculatedHeight =
            (constraints.maxHeight - spacing * (prayers.length - 1)) /
            prayers.length;

        // Max height is capped at 90 so it doesn't look stretched on very tall screens,
        // but it is allowed to shrink as needed to prevent overflow.
        final itemHeight = calculatedHeight.clamp(0.0, 90.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < prayers.length; i++) ...[
                SizedBox(
                  height: itemHeight,
                  child: MobilePrayerRow(
                    prayer: prayers[i],
                    isActive: prayers[i].key == activeKey,
                    is24HourFormat: is24HourFormat,
                    adhanOffset: adhanOffsets[prayers[i].key] ?? 0,
                  ),
                ),
                if (i < prayers.length - 1) const SizedBox(height: spacing),
              ],
            ],
          ),
        );
      },
    );
  }
}
