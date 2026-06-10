import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../settings/domain/entities/app_settings.dart';
import 'classic/classic_right_panel.dart';
import 'classic/classic_visuals.dart';
import 'classic_top_bar.dart';
import 'home_ticker_bar.dart';
import 'prayer_panel.dart';

/// Classic layout: top bar + prayer list on the left + clock/countdown on the
/// right, wrapped in the mosque-display inset gold frame.
class HomeClassicLayout extends StatelessWidget {
  final AccentPalette palette;
  final bool isIqamaCountdown;
  final AppSettings settings;
  final double screenW;
  final double screenH;
  final FocusNode quranFocusNode;
  final FocusNode takbeeratFocusNode;
  final String takbeeratReciterUrl;
  final FocusNode mainFocusNode;

  const HomeClassicLayout({
    required this.palette,
    required this.isIqamaCountdown,
    required this.settings,
    required this.screenW,
    required this.screenH,
    required this.quranFocusNode,
    required this.takbeeratFocusNode,
    required this.takbeeratReciterUrl,
    required this.mainFocusNode,
    super.key,
  });

  // Mosque mode hides every audio toggle — the muezzin handles live audio.
  bool get _showQuran =>
      !settings.isMosqueMode &&
      settings.isQuranEnabled &&
      settings.hasQuranReciter &&
      !isIqamaCountdown;
  bool get _showTakbeerat =>
      !settings.isMosqueMode &&
      takbeeratReciterUrl.isNotEmpty &&
      !isIqamaCountdown;

  @override
  Widget build(BuildContext context) {
    final pad = screenH * 0.028;
    final vis = ClassicVisuals(ThemeColors.of(settings.isDarkMode), palette);
    return Stack(
      children: [
        Column(
          children: [
            ClassicTopBar(palette: palette),
            Expanded(
              child: Row(
                children: [
                  // Prayer list (left).
                  SizedBox(
                    width: screenW * 0.34,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(pad, pad * 0.8, 0, pad),
                      child: const PrayerPanel(),
                    ),
                  ),
                  SizedBox(width: screenW * 0.02),
                  // Clock + countdown column (right).
                  Expanded(
                    child: ClassicRightPanel(
                      palette: palette,
                      isIqamaCountdown: isIqamaCountdown,
                      settings: settings,
                      screenW: screenW,
                      screenH: screenH,
                      showQuran: _showQuran,
                      showTakbeerat: _showTakbeerat,
                      quranFocusNode: quranFocusNode,
                      takbeeratFocusNode: takbeeratFocusNode,
                      takbeeratReciterUrl: takbeeratReciterUrl,
                      mainFocusNode: mainFocusNode,
                    ),
                  ),
                ],
              ),
            ),
            if (settings.isTickerEnabled)
              Padding(
                // Ticker dropped closer to the bottom edge, but kept just
                // inside the decorative gold frame (screenH * 0.020 inset) and
                // clear of TV overscan so the text never clips at the bottom.
                padding: EdgeInsets.fromLTRB(pad, 0, pad, pad * 0.8),
                child: SizedBox(
                  height: screenH * 0.065,
                  child: HomeTickerBar(
                    palette: palette,
                    isDarkMode: settings.isDarkMode,
                  ),
                ),
              ),
          ],
        ),
        // Vignette darkens the corners in dark mode for depth (design
        // box-shadow:inset). Below the frame so the border stays crisp.
        if (settings.isDarkMode)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.95,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.22),
                    ],
                    stops: const [0.72, 1.0],
                  ),
                ),
              ),
            ),
          ),
        // Decorative inset gold frame (design #screen::after).
        Positioned.fill(
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.all(screenH * 0.020),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: vis.gold.withValues(alpha: 0.10),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
