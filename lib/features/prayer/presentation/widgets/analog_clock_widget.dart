import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';
import 'analog_clock_painter.dart';

class AnalogClockWidget extends StatelessWidget {
  final AccentPalette palette;
  final bool compact;
  final bool tiny;

  const AnalogClockWidget({
    super.key,
    required this.palette,
    this.compact = false,
    this.tiny = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final now = context.select((PrayerBloc b) => b.state.now);
    final screenH = MediaQuery.of(context).size.height;
    final tc = ThemeColors.of(settings.isDarkMode);

    final diameter = tiny
        ? screenH * 0.11
        : compact
            ? screenH * 0.26
            : screenH * 0.40;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: AnalogClockPainter(
          now: now,
          palette: palette,
          tc: tc,
        ),
      ),
    );
  }
}
