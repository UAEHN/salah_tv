import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';
import '../../../settings/presentation/settings_provider.dart';
import 'classic/classic_visuals.dart';

/// Top bar: city + country on the right, separated from the body by a faint
/// hairline. The date now lives beneath the clock (see [ClassicClockDate]).
class ClassicTopBar extends StatelessWidget {
  final AccentPalette palette;

  const ClassicTopBar({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = l.localeName;
    final settings = context.watch<SettingsProvider>().settings;
    final vis = ClassicVisuals(ThemeColors.of(settings.isDarkMode), palette);
    final screenH = MediaQuery.of(context).size.height;

    final city = cityLabel(
      settings.selectedCity,
      locale: locale,
      countryKey: settings.selectedCountry,
    );
    final country = countryLabel(settings.selectedCountry, locale: locale);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        screenH * 0.04,
        screenH * 0.012,
        screenH * 0.04,
        screenH * 0.022,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: vis.line, width: 1)),
      ),
      // TV is fixed LTR: location sits on the right. The location cluster is
      // laid out RTL so the pin leads on the right.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: vis.goldHi,
                size: screenH * 0.027,
              ),
              SizedBox(width: screenH * 0.011),
              Text(
                city,
                style: TextStyle(
                  fontSize: screenH * 0.028,
                  fontWeight: FontWeight.w600,
                  color: vis.fg,
                ),
              ),
              SizedBox(width: screenH * 0.014),
              Container(
                width: 1,
                height: screenH * 0.022,
                color: vis.lineStrong,
              ),
              SizedBox(width: screenH * 0.014),
              Text(
                country,
                style: TextStyle(
                  fontSize: screenH * 0.020,
                  fontWeight: FontWeight.w500,
                  color: vis.fgMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
