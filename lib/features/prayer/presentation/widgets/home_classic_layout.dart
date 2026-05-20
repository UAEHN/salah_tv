import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../settings/domain/entities/app_settings.dart';
import 'clock_widget.dart';
import 'current_surah_strip.dart';
import 'date_widget.dart';
import 'home_quran_button.dart';
import 'home_takbeerat_button.dart';
import 'iqama_countdown_widget.dart';
import 'next_prayer_widget.dart';
import 'prayer_panel.dart';

/// Classic layout: prayer times on left, clock/countdown on right.
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

  // Mosque mode hides every audio toggle on the home view — the muezzin/
  // imam handles all live audio in the room.
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
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: screenW * 0.30,
                margin: EdgeInsets.all(screenH * 0.03),
                child: const PrayerPanel(),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenW * 0.04,
                      vertical: screenH * 0.03,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClockWidget(palette: palette),
                        SizedBox(height: screenH * 0.01),
                        DateWidget(palette: palette),
                        SizedBox(height: screenH * 0.04),
                        // RepaintBoundary isolates the FadeTransition/SlideTransition
                        // animation to this layer only; ClockWidget and DateWidget
                        // (siblings above) stay on the parent layer and don't repaint
                        // during the iqama-countdown toggle transition.
                        RepaintBoundary(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
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
                        AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          child: _buildAudioToggleBlock(screenH),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioToggleBlock(double screenH) {
    if (!_showQuran && !_showTakbeerat) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: screenH * 0.022),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showQuran)
            HomeQuranButton(
              palette: palette,
              isDarkMode: settings.isDarkMode,
              serverUrl: settings.quranReciterServerUrl,
              focusNode: quranFocusNode,
              onEscape: () => mainFocusNode.requestFocus(),
              onDown: _showTakbeerat
                  ? () => takbeeratFocusNode.requestFocus()
                  : null,
            ),
          if (_showQuran) CurrentSurahStrip(palette: palette),
          if (_showQuran && _showTakbeerat)
            SizedBox(height: screenH * 0.012),
          if (_showTakbeerat)
            HomeTakbeeratButton(
              palette: palette,
              isDarkMode: settings.isDarkMode,
              reciterUrl: takbeeratReciterUrl,
              focusNode: takbeeratFocusNode,
              onEscape: _showQuran
                  ? () => quranFocusNode.requestFocus()
                  : () => mainFocusNode.requestFocus(),
            ),
        ],
      ),
    );
  }
}
