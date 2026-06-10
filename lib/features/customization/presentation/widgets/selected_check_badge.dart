import 'package:flutter/material.dart';

import '../../../../core/mobile_theme.dart';

/// Small filled circle with a check icon, anchored at top-end of preview
/// cards to indicate the currently active selection.
class SelectedCheckBadge extends StatelessWidget {
  final bool isVisible;
  final double size;

  const SelectedCheckBadge({
    super.key,
    required this.isVisible,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      scale: isVisible ? 1.0 : 0.0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      ),
    );
  }
}
