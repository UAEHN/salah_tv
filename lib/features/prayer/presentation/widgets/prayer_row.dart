import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/time_formatters.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../bloc/prayer_ui_logic.dart';
import 'classic/classic_visuals.dart';
import 'prayer_time_column.dart';

/// One classic prayer row: a status dot + name on the right, the Adhan/Iqama
/// time cell on the left. The next prayer gets the active theme fill.
class PrayerRow extends StatelessWidget {
  final PrayerEntry prayer;
  final bool isNext;
  final AppSettings settings;
  final int iqamaDelay;
  final int adhanOffset;

  const PrayerRow({
    super.key,
    required this.prayer,
    required this.isNext,
    required this.settings,
    required this.iqamaDelay,
    this.adhanOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final palette = getThemePalette(settings.themeColorKey);
    final vis = ClassicVisuals(ThemeColors.of(settings.isDarkMode), palette);
    final timeModel = mapPrayerTimeUiModel(
      baseTime: prayer.time,
      adhanOffsetMinutes: adhanOffset,
      iqamaDelayMinutes: iqamaDelay,
      use24HourFormat: settings.use24HourFormat,
      localeCode: settings.locale,
    );
    final iqamaPeriod = formatPrayerPeriod(
      timeModel.iqamaTime,
      use24Hour: settings.use24HourFormat,
      localeCode: settings.locale,
    );
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final isDim = !prayer.isCountable;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: isNext
          ? EdgeInsets.symmetric(
              horizontal: screenH * 0.010,
              vertical: screenH * 0.006,
            )
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: isNext ? vis.activeRowGradient : null,
        borderRadius: isNext ? BorderRadius.circular(18) : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: screenH * 0.030),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _Dot(
                  vis: vis,
                  isNext: isNext,
                  isDim: isDim,
                  size: screenH * 0.012,
                ),
                SizedBox(width: screenH * 0.020),
                Flexible(
                  child: Text(
                    localizedPrayerName(context, prayer.key),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: screenH * 0.039,
                      fontWeight: isNext
                          ? FontWeight.w700
                          : (isDim ? FontWeight.w500 : FontWeight.w600),
                      color: isNext
                          ? vis.onAccent
                          : (isDim ? vis.fgSec : vis.fg),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: screenW * 0.135,
            child: PrayerTimeColumn(
              adhanTime: timeModel.timeText,
              adhanPeriod: timeModel.periodText,
              iqamaTime: timeModel.iqamaText,
              iqamaPeriod: iqamaPeriod,
              isCountable: prayer.isCountable,
              isNext: isNext,
              vis: vis,
              screenH: screenH,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final ClassicVisuals vis;
  final bool isNext;
  final bool isDim;
  final double size;

  const _Dot({
    required this.vis,
    required this.isNext,
    required this.isDim,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (isNext) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: vis.goldHi,
          shape: BoxShape.circle,
          border: Border.all(color: vis.onAccent, width: size * 0.22),
          boxShadow: [
            BoxShadow(
              color: vis.onAccent.withValues(alpha: 0.36),
              spreadRadius: size * 0.5,
            ),
          ],
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: vis.fgMuted.withValues(alpha: isDim ? 0.45 : 1.0),
          width: 1.6,
        ),
      ),
    );
  }
}
