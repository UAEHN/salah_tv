import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/qibla_accuracy.dart';

/// Inline accuracy hint shown under the page title — a small colored dot
/// followed by a single word.
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.65),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: MobileColors.onSurface(context).withValues(alpha: 0.75),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Color _colorFor(QiblaAccuracy acc) => switch (acc) {
    QiblaAccuracy.high => const Color(0xFF22A06B),
    QiblaAccuracy.medium => const Color(0xFFCB8A2A),
    QiblaAccuracy.low => const Color(0xFFD9534F),
  };
}
