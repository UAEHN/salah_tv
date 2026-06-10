import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';

class PrayerPanelHeader extends StatelessWidget {
  final AccentPalette palette;
  final String selectedCity;
  final String selectedCountry;
  // kept for API compatibility — rendering no longer branches on this flag
  final bool isMultiCity;

  const PrayerPanelHeader({
    super.key,
    required this.palette,
    required this.selectedCity,
    required this.selectedCountry,
    required this.isMultiCity,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;
    final label = cityLabel(
      selectedCity,
      locale: locale,
      countryKey: selectedCountry,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      decoration: BoxDecoration(gradient: palette.gradient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_rounded,
            color: Colors.white.withValues(alpha: 0.88),
            size: 14,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
