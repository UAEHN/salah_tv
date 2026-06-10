import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import 'package:ghasaq/core/app_colors.dart';
import 'package:ghasaq/features/prayer/presentation/bloc/prayer_bloc.dart';
import 'package:ghasaq/features/prayer/presentation/widgets/analog_clock_widget.dart';
import 'package:ghasaq/features/settings/presentation/settings_provider.dart';
import 'classic_visuals.dart';

/// Classic ("mosque display") clock: large hours:minutes in [fg] with a gold
/// blinking colon, gold seconds trailing on the right, and a muted AM/PM on
/// the left — laid out RTL so seconds sit on the right and AM/PM on the left.
class ClassicClock extends StatelessWidget {
  final AccentPalette palette;

  const ClassicClock({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final isAnalog = context.select<SettingsProvider, bool>(
      (p) => p.settings.isAnalogClock,
    );
    if (isAnalog) return AnalogClockWidget(palette: palette);
    return _DigitalClassicClock(palette: palette);
  }
}

class _DigitalClassicClock extends StatelessWidget {
  final AccentPalette palette;

  const _DigitalClassicClock({required this.palette});

  @override
  Widget build(BuildContext context) {
    final (use24h, isDark, isMosque) = context
        .select<SettingsProvider, (bool, bool, bool)>(
          (p) => (
            p.settings.use24HourFormat,
            p.settings.isDarkMode,
            p.settings.isMosqueMode,
          ),
        );
    final now = context.select((PrayerBloc b) => b.state.now);
    final vis = ClassicVisuals(ThemeColors.of(isDark), palette);
    final screenH = MediaQuery.of(context).size.height;

    final hhmm = use24h
        ? DateFormat('HH:mm', 'en').format(now)
        : DateFormat('hh:mm', 'en').format(now);
    final parts = hhmm.split(':');
    final secondsStr = DateFormat('ss', 'en').format(now);
    final amPm = use24h ? null : (now.hour < 12 ? 'ص' : 'م');

    final mainSize = screenH * (isMosque ? 0.205 : 0.185);
    final secSize = screenH * (isMosque ? 0.066 : 0.059);
    final ampmSize = screenH * 0.034;

    const tnum = [FontFeature.tabularFigures()];

    // RepaintBoundary isolates the per-second invalidation to this layer.
    return RepaintBoundary(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              secondsStr,
              style: TextStyle(
                fontSize: secSize,
                fontWeight: FontWeight.w500,
                color: vis.goldHi,
                height: 1,
                fontFeatures: tnum,
              ),
            ),
            SizedBox(width: screenH * 0.012),
            RichText(
              textDirection: TextDirection.ltr,
              text: TextSpan(
                style: TextStyle(
                  fontSize: mainSize,
                  fontWeight: FontWeight.w600,
                  color: vis.fg,
                  height: 1,
                  letterSpacing: -2,
                  fontFeatures: tnum,
                ),
                children: [
                  TextSpan(text: parts[0]),
                  TextSpan(
                    text: ':',
                    style: TextStyle(
                      color: vis.goldHi.withValues(
                        alpha: vis.tc.isDark ? 0.70 : 0.88,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: parts[1]),
                ],
              ),
            ),
            if (amPm != null) ...[
              SizedBox(width: screenH * 0.014),
              Text(
                amPm,
                style: TextStyle(
                  fontSize: ampmSize,
                  fontWeight: FontWeight.w600,
                  color: vis.fgSec,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
