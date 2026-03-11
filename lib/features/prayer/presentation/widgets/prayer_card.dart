import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../models/daily_prayer_times.dart';
import '../../../../models/app_settings.dart';
import '../../../../core/app_colors.dart';

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
      builder: (_, _) {
        final p = widget.isPreAlert
            ? Curves.easeInOut.transform(_pulseCtrl.value)
            : 0.0;

        final borderColor = widget.isPreAlert
            ? palette.primary.withValues(alpha: 0.30 + p * 0.20)
            : widget.isNext
                ? palette.primary.withValues(alpha: 0.5)
                : tc.borderGlass;

        final glowColor = widget.isPreAlert
            ? palette.primary.withValues(alpha: 0.08 + p * 0.12)
            : widget.isNext
                ? palette.glow.withValues(alpha: 0.2)
                : Colors.black.withValues(
                    alpha: widget.settings.isDarkMode ? 0.2 : 0.04,
                  );

        return Container(
          decoration: BoxDecoration(
            color: widget.isNext ? null : tc.bgSurface,
            gradient: widget.isNext
                ? LinearGradient(
                    colors: [
                      palette.primary.withValues(alpha: 0.15),
                      palette.secondary.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: widget.isNext ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: widget.isPreAlert ? 8 + p * 6 : (widget.isNext ? 12 : 8),
                spreadRadius: widget.isPreAlert ? p * 1 : (widget.isNext ? 1 : 0),
                offset: widget.isNext ? Offset.zero : const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isNext)
                Container(
                  height: 3,
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
                  decoration: BoxDecoration(
                    color: widget.isPreAlert ? palette.primary.withValues(alpha: 0.4 + p * 0.2) : null,
                    gradient: widget.isPreAlert ? null : palette.horizontalGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              SizedBox(height: screenH * 0.008),
              Icon(
                _icon(widget.prayer.key),
                size: screenH * 0.050,
                color: widget.isNext ? tc.textPrimary : tc.textSecondary,
              ),
              SizedBox(height: screenH * 0.008),
              Text(
                widget.prayer.name,
                style: TextStyle(
                  fontSize: screenH * 0.040,
                  fontWeight: widget.isNext ? FontWeight.w700 : FontWeight.w500,
                  color: tc.textPrimary,
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: screenH * 0.006),
                color: widget.isNext
                    ? palette.primary.withValues(alpha: 0.25)
                    : tc.borderGlass,
              ),
              Text(
                _formatTime(adjusted),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: screenH * 0.045,
                  fontWeight: FontWeight.w700,
                  color: tc.textPrimary,
                ),
              ),
              if (widget.prayer.isCountable) ...[
                SizedBox(height: screenH * 0.002),
                Text(
                  'إقامة ${_formatTime(iqama)}',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: screenH * 0.026, color: tc.textMuted),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
