import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/qibla_accuracy.dart';

/// Pill badge showing compass accuracy level with a colored dot indicator.
class QiblaAccuracyBadge extends StatelessWidget {
  final QiblaAccuracy accuracy;

  const QiblaAccuracyBadge({super.key, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = _colorFor(accuracy);
    final label = switch (accuracy) {
      QiblaAccuracy.high => l.qiblaAccuracyHigh,
      QiblaAccuracy.medium => l.qiblaAccuracyMedium,
      QiblaAccuracy.low => l.qiblaAccuracyLow,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MobileColors.cardColor(context).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: MobileTextStyles.labelSm(context).copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(QiblaAccuracy acc) => switch (acc) {
        QiblaAccuracy.high => const Color(0xFF4CAF50),
        QiblaAccuracy.medium => const Color(0xFFFFC107),
        QiblaAccuracy.low => const Color(0xFFFF5722),
      };
}
