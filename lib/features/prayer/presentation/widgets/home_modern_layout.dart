import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../settings/domain/entities/app_settings.dart';
import 'hero_card.dart';
import 'home_quran_button.dart';
import 'home_takbeerat_button.dart';
import 'home_ticker_bar.dart';
import 'info_card.dart';
import 'prayer_card_strip.dart';
import 'top_bar.dart';

/// Modern layout: hero card + info card side by side, prayer strip at bottom.
class HomeModernLayout extends StatelessWidget {
  final AccentPalette palette;
  final bool isIqamaCountdown;
  final AppSettings settings;
  final double screenW;
  final double screenH;
  final FocusNode quranFocusNode;
  final FocusNode takbeeratFocusNode;
  final String takbeeratReciterUrl;
  final FocusNode mainFocusNode;

  const HomeModernLayout({
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

  @override
  Widget build(BuildContext context) {
    // TV overscan margin: many TV boxes clip a few % off each edge, cutting the
    // bottom-most element. A small bottom inset keeps the ticker (or the prayer
    // strip when the ticker is off) fully visible without lifting the layout.
    final bottomSafe = screenH * 0.03;
    // Ticker sits lower (closer to the bottom edge) than the strip-overscan
    // margin — a slimmer inset that still keeps the text clear of overscan clip.
    final tickerBottom = screenH * 0.012;
    return Column(
      children: [
        TopBar(palette: palette),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenW * 0.025,
              vertical: screenH * 0.015,
            ),
            child: Row(
              children: [
                const Expanded(flex: 58, child: HeroCard()),
                SizedBox(width: screenW * 0.015),
                Expanded(
                  flex: 38,
                  child: () {
                    // Mosque mode hides every audio toggle on the home view —
                    // the muezzin/imam handles all live audio in the room.
                    final mosque = settings.isMosqueMode;
                    final showQuran =
                        !mosque &&
                        settings.isQuranEnabled &&
                        settings.hasQuranReciter &&
                        !isIqamaCountdown;
                    final showTakbeerat =
                        !mosque &&
                        takbeeratReciterUrl.isNotEmpty &&
                        !isIqamaCountdown;
                    return InfoCard(
                      palette: palette,
                      quranButton: showQuran
                          ? HomeQuranButton(
                              palette: palette,
                              isDarkMode: settings.isDarkMode,
                              serverUrl: settings.quranReciterServerUrl,
                              focusNode: quranFocusNode,
                              onEscape: () => mainFocusNode.requestFocus(),
                              onDown: showTakbeerat
                                  ? () => takbeeratFocusNode.requestFocus()
                                  : null,
                            )
                          : null,
                      takbeeratButton: showTakbeerat
                          ? HomeTakbeeratButton(
                              palette: palette,
                              isDarkMode: settings.isDarkMode,
                              reciterUrl: takbeeratReciterUrl,
                              focusNode: takbeeratFocusNode,
                              onEscape: showQuran
                                  ? () => quranFocusNode.requestFocus()
                                  : () => mainFocusNode.requestFocus(),
                            )
                          : null,
                    );
                  }(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: screenH * 0.33,
          child: Padding(
            // When the ticker is off the strip is the bottom-most element, so it
            // takes the overscan margin; otherwise just a small gap to the ticker.
            padding: EdgeInsets.only(
              bottom: settings.isTickerEnabled ? screenH * 0.015 : bottomSafe,
            ),
            child: const PrayerCardStrip(),
          ),
        ),
        if (settings.isTickerEnabled)
          Padding(
            padding: EdgeInsets.only(bottom: tickerBottom),
            child: SizedBox(
              height: screenH * 0.07,
              child: HomeTickerBar(
                palette: palette,
                isDarkMode: settings.isDarkMode,
              ),
            ),
          ),
      ],
    );
  }
}
