import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// A single row showing a label and a +/- stepper for a numeric value.
class MobilePrayerOffsetRow extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const MobilePrayerOffsetRow({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Text(
            label,
            style: MobileTextStyles.bodyMd(context).copyWith(
              color: MobileColors.onSurface(context),
              fontSize: 14,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        _StepperButton(
          icon: Icons.add_rounded,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: 52,
            child: Text(
              '$value $unit',
              style: MobileTextStyles.titleMd(context).copyWith(
                color: value != 0
                    ? MobileColors.primary
                    : MobileColors.onSurface(context),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        _StepperButton(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? MobileColors.primary.withValues(alpha: 0.12)
              : MobileColors.border(context).withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? MobileColors.primary
              : MobileColors.onSurfaceMuted(context),
        ),
      ),
    );
  }
}
