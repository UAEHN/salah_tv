import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Thin rounded overall-progress bar for the Khatma. Built on the framework's
/// [LinearProgressIndicator] — no hand-painted geometry.
class KhatmaProgressBar extends StatelessWidget {
  /// 0..1 completion.
  final double fraction;

  const KhatmaProgressBar({super.key, required this.fraction});

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: 14,
        backgroundColor: accent.withValues(alpha: 0.14),
        valueColor: AlwaysStoppedAnimation<Color>(accent),
      ),
    );
  }
}
