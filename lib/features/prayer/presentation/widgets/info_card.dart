import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/prayer_bloc.dart';
import 'clock_widget.dart';
import 'current_surah_strip.dart';
import 'date_widget.dart';

class InfoCard extends StatelessWidget {
  final AccentPalette palette;
  final Widget? quranButton;
  final Widget? takbeeratButton;

  const InfoCard({
    super.key,
    required this.palette,
    this.quranButton,
    this.takbeeratButton,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final locale = AppLocalizations.of(context).localeName;
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      // Fill the full card height so only the inner content scales — the card
      // box itself keeps its size regardless of how tall the content is.
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: screenH * 0.02),
      decoration: BoxDecoration(
        color: tc.bgSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tc.borderGlass, width: 1),
      ),
      // FittedBox keeps clock → date → audio group as one centred block and
      // scales it down when the surah card + ticker bar leave too little
      // height, so the now-playing card stays glued under the Quran button
      // instead of overflowing — matching the classic layout's behaviour.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clock (full size in info card)
            ClockWidget(palette: palette, compact: true),

            SizedBox(height: screenH * 0.01),

            // Date
            DateWidget(palette: palette, compact: true),

            // City badge — visible when the repo is multi-city OR when the
            // user picked a calculated (world) city (e.g. Turkey, France);
            // the calc repo reports isMultiCity=false but the label still
            // matters visually.
            if (context.select((PrayerBloc b) => b.state.isMultiCity) ||
                settings.isCalculatedLocation) ...[
              SizedBox(height: screenH * 0.015),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: tc.textPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: tc.textPrimary.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: tc.textSecondary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cityLabel(
                        settings.selectedCity,
                        locale: locale,
                        countryKey: settings.selectedCountry,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tc.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Audio toggles stacked vertically — Quran pill on top with its
            // surah strip, Takbeerat pill below. Vertical layout prevents the
            // Quran's stop button (which appears when playing) from pushing
            // the Takbeerat pill off-screen.
            if (quranButton != null || takbeeratButton != null) ...[
              SizedBox(height: screenH * 0.012),
              ?quranButton,
              if (quranButton != null) CurrentSurahStrip(palette: palette),
              if (quranButton != null && takbeeratButton != null)
                SizedBox(height: screenH * 0.008),
              ?takbeeratButton,
            ],
          ],
        ),
      ),
    );
  }
}
