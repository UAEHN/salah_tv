import 'package:flutter/material.dart';

import 'package:ghasaq/core/app_colors.dart';
import 'package:ghasaq/features/prayer/presentation/widgets/classic/classic_clock.dart';
import 'package:ghasaq/features/prayer/presentation/widgets/classic/classic_clock_date.dart';
import 'package:ghasaq/features/prayer/presentation/widgets/classic/classic_visuals.dart';
import 'package:ghasaq/features/prayer/presentation/widgets/current_surah_strip.dart';
import 'package:ghasaq/features/prayer/presentation/widgets/home_quran_button.dart';
import 'package:ghasaq/features/prayer/presentation/widgets/home_takbeerat_button.dart';
import 'package:ghasaq/features/prayer/presentation/widgets/iqama_countdown_widget.dart';
import 'package:ghasaq/features/prayer/presentation/widgets/next_prayer_widget.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings.dart';

/// Right column of the classic home: centred clock → divider → countdown card
/// → optional audio buttons (Quran + Takbeerat), matching the mosque-display
/// design's vertically-centred clock column.
class ClassicRightPanel extends StatelessWidget {
  final AccentPalette palette;
  final bool isIqamaCountdown;
  final AppSettings settings;
  final double screenW;
  final double screenH;
  final bool showQuran;
  final bool showTakbeerat;
  final FocusNode quranFocusNode;
  final FocusNode takbeeratFocusNode;
  final String takbeeratReciterUrl;
  final FocusNode mainFocusNode;

  const ClassicRightPanel({
    super.key,
    required this.palette,
    required this.isIqamaCountdown,
    required this.settings,
    required this.screenW,
    required this.screenH,
    required this.showQuran,
    required this.showTakbeerat,
    required this.quranFocusNode,
    required this.takbeeratFocusNode,
    required this.takbeeratReciterUrl,
    required this.mainFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final vis = ClassicVisuals(ThemeColors.of(settings.isDarkMode), palette);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.03,
        vertical: screenH * 0.02,
      ),
      // FittedBox keeps the clock → countdown → audio group as one block that
      // stays vertically centred, and scales the whole block down when the
      // surah card + ticker bar leave too little height. Without it the
      // centred Column overflows and the now-playing card slides onto the
      // ticker; with it the card stays glued under the Quran button.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClassicClock(palette: palette),
            SizedBox(height: screenH * 0.018),
            ClassicClockDate(palette: palette),
            SizedBox(height: screenH * 0.028),
            Container(
              width: screenW * 0.062,
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    vis.lineStrong,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SizedBox(height: screenH * 0.040),
            // RepaintBoundary keeps the clock on a separate GPU layer so the
            // fade/slide here never forces a clock repaint.
            RepaintBoundary(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: isIqamaCountdown
                    ? IqamaCountdownWidget(
                        key: const ValueKey('iqama'),
                        palette: palette,
                      )
                    : NextPrayerWidget(
                        key: const ValueKey('next'),
                        palette: palette,
                      ),
              ),
            ),
            if (showQuran || showTakbeerat) ...[
              SizedBox(height: screenH * 0.030),
              _AudioButtons(
                palette: palette,
                settings: settings,
                screenH: screenH,
                showQuran: showQuran,
                showTakbeerat: showTakbeerat,
                quranFocusNode: quranFocusNode,
                takbeeratFocusNode: takbeeratFocusNode,
                takbeeratReciterUrl: takbeeratReciterUrl,
                mainFocusNode: mainFocusNode,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AudioButtons extends StatelessWidget {
  final AccentPalette palette;
  final AppSettings settings;
  final double screenH;
  final bool showQuran;
  final bool showTakbeerat;
  final FocusNode quranFocusNode;
  final FocusNode takbeeratFocusNode;
  final String takbeeratReciterUrl;
  final FocusNode mainFocusNode;

  const _AudioButtons({
    required this.palette,
    required this.settings,
    required this.screenH,
    required this.showQuran,
    required this.showTakbeerat,
    required this.quranFocusNode,
    required this.takbeeratFocusNode,
    required this.takbeeratReciterUrl,
    required this.mainFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showQuran)
            HomeQuranButton(
              palette: palette,
              isDarkMode: settings.isDarkMode,
              serverUrl: settings.quranReciterServerUrl,
              focusNode: quranFocusNode,
              onEscape: () => mainFocusNode.requestFocus(),
              onDown: showTakbeerat
                  ? () => takbeeratFocusNode.requestFocus()
                  : null,
            ),
          if (showQuran) CurrentSurahStrip(palette: palette),
          if (showQuran && showTakbeerat) SizedBox(height: screenH * 0.012),
          if (showTakbeerat)
            HomeTakbeeratButton(
              palette: palette,
              isDarkMode: settings.isDarkMode,
              reciterUrl: takbeeratReciterUrl,
              focusNode: takbeeratFocusNode,
              onEscape: showQuran
                  ? () => quranFocusNode.requestFocus()
                  : () => mainFocusNode.requestFocus(),
            ),
        ],
      ),
    );
  }
}
