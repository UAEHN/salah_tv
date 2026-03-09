import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';
import '../../../settings/presentation/settings_provider.dart';
import 'clock_widget.dart';
import 'date_widget.dart';

class InfoCard extends StatelessWidget {
  final AccentPalette palette;
  final Widget? quranButton;

  const InfoCard({super.key, required this.palette, this.quranButton});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: screenH * 0.02),
      decoration: BoxDecoration(
        color: tc.bgSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tc.borderGlass, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: settings.isDarkMode ? 0.25 : 0.05,
            ),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Clock (full size in info card)
          ClockWidget(palette: palette, compact: true),

          SizedBox(height: screenH * 0.01),

          // Date
          DateWidget(palette: palette, compact: true),

          // City badge
          if (context.read<SettingsProvider>().isMultiCity) ...[
            SizedBox(height: screenH * 0.015),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cityLabel(settings.selectedCity),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: tc.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Quran button
          if (quranButton != null) ...[
            SizedBox(height: screenH * 0.02),
            quranButton!,
          ],
        ],
      ),
    );
  }
}
