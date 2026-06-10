import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';
import '../../logic/calculation_method_suggester.dart';

/// Friendly explainer shown above the method picker when the chosen
/// location sits above ~48° latitude. Tells the user, in plain language,
/// why the chosen rule matters and (in extreme cases) that Fajr/Isha will
/// be approximations on summer days.
class MobileHighLatitudeBanner extends StatelessWidget {
  final HighLatitudeBand band;
  final String highMessage;
  final String extremeMessage;

  const MobileHighLatitudeBanner({
    required this.band,
    required this.highMessage,
    required this.extremeMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (band == HighLatitudeBand.normal) return const SizedBox.shrink();
    final isExtreme = band == HighLatitudeBand.extreme;
    final color = isExtreme
        ? Colors.orange.shade700
        : MobileColors.activePrimary(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        children: [
          Icon(
            isExtreme ? Icons.warning_amber_rounded : Icons.info_outline,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isExtreme ? extremeMessage : highMessage,
              style: TextStyle(
                color: MobileColors.onSurface(context),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
