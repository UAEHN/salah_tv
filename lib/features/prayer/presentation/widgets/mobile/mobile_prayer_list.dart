import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../bloc/prayer_bloc.dart';
import '../../../../settings/presentation/settings_provider.dart';
import '../../../../../core/mobile_theme.dart';
import 'mobile_prayer_row.dart';

class MobilePrayerList extends StatelessWidget {
  const MobilePrayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final prayers = context.select(
      (PrayerBloc b) => b.state.todayPrayers?.prayersOnly ?? const [],
    );
    final nextPrayerKey = context.select(
      (PrayerBloc b) => b.state.nextPrayerKey,
    );
    final use24Hour = context.watch<SettingsProvider>().settings.use24HourFormat;

    if (prayers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: MobileColors.primaryContainer,
          strokeWidth: 2,
        ),
      );
    }

    const spacing = 10.0;
    const hPad = 20.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemHeight =
            (constraints.maxHeight - spacing * (prayers.length - 1)) /
            prayers.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            children: [
              for (int i = 0; i < prayers.length; i++) ...[
                SizedBox(
                  height: itemHeight,
                  child: MobilePrayerRow(
                    prayer: prayers[i],
                    isActive: prayers[i].key == nextPrayerKey,
                    use24Hour: use24Hour,
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
