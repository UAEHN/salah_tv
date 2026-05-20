import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../settings/domain/entities/app_settings.dart';
import 'hero_card.dart';
import 'home_quran_button.dart';
import 'home_takbeerat_button.dart';
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
                    final showQuran = !mosque &&
                        settings.isQuranEnabled &&
                        settings.hasQuranReciter &&
                        !isIqamaCountdown;
                    final showTakbeerat = !mosque &&
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
            padding: EdgeInsets.only(bottom: screenH * 0.015),
            child: const PrayerCardStrip(),
          ),
        ),
      ],
    );
  }
}
