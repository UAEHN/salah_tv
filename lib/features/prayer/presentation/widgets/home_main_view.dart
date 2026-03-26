import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../painters/arabesque_painter.dart';
import 'home_classic_layout.dart';
import 'home_modern_layout.dart';

class HomeMainView extends StatelessWidget {
  final AccentPalette palette;
  final ThemeColors tc;
  final bool isIqamaCountdown;
  final AppSettings settings;
  final double screenW;
  final double screenH;
  final FocusNode quranFocusNode;
  final FocusNode mainFocusNode;

  const HomeMainView({
    super.key,
    required this.palette,
    required this.tc,
    required this.isIqamaCountdown,
    required this.settings,
    required this.screenW,
    required this.screenH,
    required this.quranFocusNode,
    required this.mainFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: tc.bgGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ArabescPainter(color: palette.primary, opacity: 0.12),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.centerRight,
                  radius: 1.2,
                  colors: [
                    palette.glow.withValues(
                      alpha: settings.isDarkMode ? 0.12 : 0.08,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          settings.layoutStyle == 'modern'
              ? HomeModernLayout(
                  palette: palette,
                  isIqamaCountdown: isIqamaCountdown,
                  settings: settings,
                  screenW: screenW,
                  screenH: screenH,
                  quranFocusNode: quranFocusNode,
                  mainFocusNode: mainFocusNode,
                )
              : HomeClassicLayout(
                  palette: palette,
                  isIqamaCountdown: isIqamaCountdown,
                  settings: settings,
                  screenW: screenW,
                  screenH: screenH,
                  quranFocusNode: quranFocusNode,
                  mainFocusNode: mainFocusNode,
                ),
        ],
      ),
    );
  }
}
