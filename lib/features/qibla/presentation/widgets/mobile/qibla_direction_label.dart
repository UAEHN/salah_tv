import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class QiblaDirectionLabel extends StatelessWidget {
  final String label;
  final Alignment alignment;

  const QiblaDirectionLabel({
    super.key,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          label,
          style: MobileTextStyles.labelSm(context).copyWith(
            color: MobileColors.onSurfaceMuted(context).withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
