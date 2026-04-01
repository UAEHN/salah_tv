import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';

class PrayerPanelHeader extends StatelessWidget {
  final AccentPalette palette;
  final String selectedCity;
  final bool isMultiCity;

  const PrayerPanelHeader({
    super.key,
    required this.palette,
    required this.selectedCity,
    required this.isMultiCity,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        gradient: palette.gradient,
      ),
      child: Column(
        children: [
          // City badge — shown only for multi-city CSV
          if (isMultiCity) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 13),
                  const SizedBox(width: 4),
                  Text(
                    cityLabel(selectedCity, locale: locale),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.95),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
