import 'package:flutter/material.dart';

import '../../../../../core/localization/prayer_name_localizer.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/daily_prayer_times.dart';
import '../../bloc/prayer_ui_logic.dart';
import 'mobile_prayer_row_parts.dart';
import 'mobile_prayer_row_theme.dart';
import 'mobile_prayer_visuals.dart';

class MobilePrayerRow extends StatelessWidget {
  final PrayerEntry prayer;
  final bool isActive;
  final bool isPassed;
  final bool is24HourFormat;
  final int adhanOffset;
  final double progress;

  const MobilePrayerRow({
    super.key,
    required this.prayer,
    required this.isActive,
    this.isPassed = false,
    required this.is24HourFormat,
    this.adhanOffset = 0,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final isDark = MobileColors.isDark(context);
    final colors = mobilePrayerAccentPair(context, prayer.key);
    final accentBright = colors.$1;
    final accentDeep = colors.$2;
    final timeModel = mapPrayerTimeUiModel(
      baseTime: prayer.time,
      adhanOffsetMinutes: adhanOffset,
      iqamaDelayMinutes: 0,
      use24HourFormat: is24HourFormat,
      localeCode: localeCode,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: isActive
          ? buildMobilePrayerActiveDecoration(
              context,
              isDark,
              accentBright,
              accentDeep,
            )
          : buildMobilePrayerInactiveDecoration(
              context,
              isDark,
              accentBright,
              accentDeep,
            ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxHeight > 0 && constraints.maxHeight < 80;
          final containerSize = isCompact ? 38.0 : 48.0;
          final contentSize = isCompact ? 26.0 : 34.0;
          final vPad = isCompact ? 12.0 : 18.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: vPad),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  MobilePrayerIcon(
                    prayerKey: prayer.key,
                    isActive: isActive,
                    isDark: isDark,
                    containerSize: containerSize,
                    contentSize: contentSize,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: MobilePrayerInfo(
                      name: localizedPrayerName(context, prayer.key),
                      isActive: isActive,
                    ),
                  ),
                  MobilePrayerTime(
                    timeText: timeModel.timeText,
                    periodText: timeModel.periodText,
                    isActive: isActive,
                    isCompact: isCompact,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
