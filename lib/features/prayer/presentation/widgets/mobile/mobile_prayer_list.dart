import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../settings/presentation/settings_provider.dart';
import '../../bloc/prayer_bloc.dart';
import '../../bloc/prayer_progress_calculator.dart' as progress_calc;
import '../../bloc/prayer_ui_logic.dart';
import 'mobile_prayer_row.dart';

/// Prayer times list with "أوقات الصلاة اليوم" section title.
class MobilePrayerList extends StatelessWidget {
  final bool is24HourFormat;

  const MobilePrayerList({super.key, required this.is24HourFormat});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<PrayerBloc>().state;
    final prayers = state.displayedPrayers?.prayersOnly ?? const [];
    final isViewingToday = state.isViewingToday;
    final isBusy = state.isDateNavigationBusy;
    final nextPrayerKey = state.nextPrayerKey;
    final activeCyclePrayerKey = state.activeCyclePrayerKey;
    final adhanOffsets = context.select(
      (SettingsProvider p) => p.settings.adhanOffsets,
    );

    final activeKey = resolveMobileActivePrayerKey(
      isViewingToday: isViewingToday,
      activeCyclePrayerKey: activeCyclePrayerKey,
      nextPrayerKey: nextPrayerKey,
    );

    final progress = progress_calc.countdownArcProgress(state);

    if (prayers.isEmpty) {
      return Center(
        child: isBusy
            ? const CircularProgressIndicator(
                color: MobileColors.primaryContainer,
                strokeWidth: 2,
              )
            : Text(
                l.noPrayerDataForDate,
                style: MobileTextStyles.bodyMd(
                  context,
                ).copyWith(color: MobileColors.onSurfaceMuted(context)),
                textDirection: TextDirection.rtl,
              ),
      );
    }

    return _PrayerCardsList(
      prayers: prayers,
      activeKey: activeKey,
      is24HourFormat: is24HourFormat,
      adhanOffsets: adhanOffsets,
      progress: progress,
      now: isViewingToday ? state.now : null,
    );
  }
}

class _PrayerCardsList extends StatelessWidget {
  final List prayers;
  final String activeKey;
  final bool is24HourFormat;
  final Map<String, int> adhanOffsets;
  final double progress;
  final DateTime? now;

  const _PrayerCardsList({
    required this.prayers,
    required this.activeKey,
    required this.is24HourFormat,
    required this.adhanOffsets,
    required this.progress,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;
    const hPad = 20.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < prayers.length; i++) ...[
            Flexible(
              child: TweenAnimationBuilder<double>(
                key: ValueKey('prayer_row_${prayers[i].key}'),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Interval(
                  (i * 0.1).clamp(0.0, 1.0),
                  1.0,
                  curve: Curves.easeOutCubic,
                ),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: MobilePrayerRow(
                  prayer: prayers[i],
                  isActive: prayers[i].key == activeKey,
                  isPassed: isPrayerPassedByTime(
                    prayerTime: prayers[i].time,
                    now: now,
                    prayerKey: prayers[i].key,
                    activeKey: activeKey,
                  ),
                  is24HourFormat: is24HourFormat,
                  adhanOffset: adhanOffsets[prayers[i].key] ?? 0,
                  progress: prayers[i].key == activeKey ? progress : 0.0,
                ),
              ),
            ),
            if (i < prayers.length - 1) const SizedBox(height: spacing),
          ],
        ],
      ),
    );
  }
}
