import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_colors.dart';
import '../../logic/calculation_method_suggester.dart';
import '../../settings_provider.dart';

/// TV-skinned version of the high-latitude explainer. Plain info banner
/// for 48°–55°, warning banner for >= 55° where Fajr/Isha become
/// approximations on summer days.
class TvHighLatitudeBanner extends StatelessWidget {
  final HighLatitudeBand band;
  final String highMessage;
  final String extremeMessage;

  const TvHighLatitudeBanner({
    required this.band,
    required this.highMessage,
    required this.extremeMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (band == HighLatitudeBand.normal) return const SizedBox.shrink();
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final isExtreme = band == HighLatitudeBand.extreme;
    final color = isExtreme
        ? Colors.orange.shade400
        : getThemePalette(settings.themeColorKey).primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            isExtreme ? Icons.warning_amber_rounded : Icons.info_outline,
            color: color,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isExtreme ? extremeMessage : highMessage,
              style: TextStyle(
                color: tc.textPrimary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
