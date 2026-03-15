import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../domain/entities/daily_prayer_times.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../../core/app_colors.dart';
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

  String _formatTime(DateTime dt) {
    if (widget.settings.use24HourFormat) return DateFormat('HH:mm').format(dt);
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour < 12 ? 'ص' : 'م'}';
  }

  IconData _icon(String key) => switch (key) {
    'fajr' => Icons.wb_twilight_rounded,
    'sunrise' => Icons.brightness_high_rounded,
    'dhuhr' => Icons.wb_sunny_rounded,
    'asr' => Icons.wb_sunny_outlined,
    'maghrib' => Icons.brightness_4_rounded,
    'isha' => Icons.nights_stay_rounded,
    _ => Icons.star_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final palette = getThemePalette(widget.settings.themeColorKey);
    final tc = ThemeColors.of(widget.settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;
    final adjusted = widget.prayer.time.add(Duration(minutes: widget.adhanOffset));
    final iqama = adjusted.add(Duration(minutes: widget.iqamaDelay));

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
        formattedTime: _formatTime(adjusted),
        formattedIqama: _formatTime(iqama),
        icon: _icon(widget.prayer.key),
      ),
    );
  }
}
