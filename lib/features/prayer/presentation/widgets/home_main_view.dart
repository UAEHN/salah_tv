import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../painters/arabesque_painter.dart';
import 'classic/classic_visuals.dart';
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
  final FocusNode takbeeratFocusNode;
  final String takbeeratReciterUrl;
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
    required this.takbeeratFocusNode,
    required this.takbeeratReciterUrl,
    required this.mainFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    // Mosque mode boosts text so the home view stays legible from across a
    // prayer hall. Scaling is applied via [MediaQuery.textScaler] so every
    // descendant Text honours it without per-widget plumbing.
    // Classic uses its own background (deep navy in dark, a cool light slate in
    // light) so the white panels keep high contrast in either mode.
    final isClassic = settings.layoutStyle == 'classic';
    final base = Container(
      decoration: BoxDecoration(
        gradient: isClassic
            ? ClassicVisuals(tc, palette).bgGradient
            : tc.bgGradient,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            // RepaintBoundary gives the static background its own GPU layer so
            // sibling animations (clock, AnimatedSwitcher) never force it to repaint.
            child: RepaintBoundary(
              child: CustomPaint(
                painter: ArabescPainter(
                  color: palette.primary,
                  opacity: isClassic
                      ? (settings.isDarkMode ? 0.105 : 0.16)
                      : 0.12,
                ),
              ),
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
                  takbeeratFocusNode: takbeeratFocusNode,
                  takbeeratReciterUrl: takbeeratReciterUrl,
                  mainFocusNode: mainFocusNode,
                )
              : HomeClassicLayout(
                  palette: palette,
                  isIqamaCountdown: isIqamaCountdown,
                  settings: settings,
                  screenW: screenW,
                  screenH: screenH,
                  quranFocusNode: quranFocusNode,
                  takbeeratFocusNode: takbeeratFocusNode,
                  takbeeratReciterUrl: takbeeratReciterUrl,
                  mainFocusNode: mainFocusNode,
                ),
        ],
      ),
    );
    if (!settings.isMosqueMode) return base;
    final current = MediaQuery.textScalerOf(context);
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(current.scale(1.0) * 1.25)),
      child: base,
    );
  }
}
