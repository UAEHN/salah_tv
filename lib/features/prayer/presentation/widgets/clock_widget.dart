import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';
import 'analog_clock_widget.dart';

class ClockWidget extends StatelessWidget {
  final AccentPalette palette;
  final bool compact;
  final bool tiny;

  const ClockWidget({
    super.key,
    required this.palette,
    this.compact = false,
    this.tiny = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAnalog = context.select<SettingsProvider, bool>(
      (p) => p.settings.isAnalogClock,
    );
    if (isAnalog) {
      return AnalogClockWidget(palette: palette, compact: compact, tiny: tiny);
    }
    return _DigitalClock(palette: palette, compact: compact, tiny: tiny);
  }
}

class _DigitalClock extends StatelessWidget {
  final AccentPalette palette;
  final bool compact;
  final bool tiny;

  const _DigitalClock({
    required this.palette,
    this.compact = false,
    this.tiny = false,
  });

  @override
  Widget build(BuildContext context) {
    final (use24h, isDark) = context.select<SettingsProvider, (bool, bool)>(
      (p) => (p.settings.use24HourFormat, p.settings.isDarkMode),
    );
    final now = context.select((PrayerBloc b) => b.state.now);
    final screenH = MediaQuery.of(context).size.height;
    final tc = ThemeColors.of(isDark);

    final timeStr = use24h
        ? DateFormat('HH:mm').format(now)
        : DateFormat('hh:mm').format(now);
    final secondsStr = DateFormat(':ss').format(now);

    final mainSize = tiny
        ? screenH * 0.045
        : compact
            ? screenH * 0.10
            : screenH * 0.18;
    final secSize = tiny
        ? screenH * 0.03
        : compact
            ? screenH * 0.05
            : screenH * 0.08;

    // RepaintBoundary isolates the per-second text invalidation to this layer
    // so it never forces parents (info card, background gradients) to repaint.
    return RepaintBoundary(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: RichText(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: timeStr,
            style: TextStyle(
              fontSize: mainSize,
              fontWeight: FontWeight.w700,
              color: tc.textPrimary,
              letterSpacing: tiny ? 1 : 4,
              height: 1.0,
            ),
            children: [
              TextSpan(
                text: secondsStr,
                style: TextStyle(
                  fontSize: secSize,
                  fontWeight: FontWeight.w700,
                  color: tc.textSecondary,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
