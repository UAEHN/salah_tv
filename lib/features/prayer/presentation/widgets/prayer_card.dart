import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../bloc/prayer_ui_logic.dart';
import 'prayer_card_content.dart';

class PrayerCard extends StatefulWidget {
  final PrayerEntry prayer;
  final bool isNext;
  final bool isPassed;
  final bool isPreAlert;
  final AppSettings settings;
  final int iqamaDelay;
  final int adhanOffset;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.isNext,
    required this.isPassed,
    required this.settings,
    required this.iqamaDelay,
    this.isPreAlert = false,
    this.adhanOffset = 0,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.isPreAlert) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PrayerCard old) {
    super.didUpdateWidget(old);
    if (widget.isPreAlert == old.isPreAlert) return;
    if (widget.isPreAlert) {
      _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  IconData _icon(String key) => switch (key) {
    'fajr' => Icons.wb_twilight_rounded,
    'sunrise' => Icons.brightness_5_rounded,
    'dhuhr' => Icons.wb_sunny_rounded,
    'asr' => Icons.brightness_medium_rounded,
    'maghrib' => Icons.nights_stay_rounded,
    'isha' => Icons.bedtime_rounded,
    _ => Icons.star_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final palette = getThemePalette(widget.settings.themeColorKey);
    final tc = ThemeColors.of(widget.settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;
    final timeModel = mapPrayerTimeUiModel(
      baseTime: widget.prayer.time,
      adhanOffsetMinutes: widget.adhanOffset,
      iqamaDelayMinutes: widget.iqamaDelay,
      use24HourFormat: widget.settings.use24HourFormat,
      localeCode: widget.settings.locale,
    );

    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, _) => PrayerCardContent(
        pulse: widget.isPreAlert
            ? Curves.easeInOut.transform(_pulseCtrl.value)
            : 0.0,
        isPreAlert: widget.isPreAlert,
        isNext: widget.isNext,
        isDarkMode: widget.settings.isDarkMode,
        palette: palette,
        tc: tc,
        screenH: screenH,
        prayer: widget.prayer,
        formattedTime: timeModel.timeText,
        formattedIqama: timeModel.iqamaText,
        icon: _icon(widget.prayer.key),
      ),
    );
  }
}
