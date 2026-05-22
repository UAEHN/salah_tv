import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/mobile_theme.dart';
import 'mobile_prayer_offset_stepper_button.dart';

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

  void _step(int delta) {
    final next = (value + delta).clamp(min, max);
    if (next != value) {
      HapticFeedback.selectionClick();
      onChanged(next);
    }
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    onChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    final primary = MobileColors.activePrimary(context);
    final canReset = value != 0 && min <= 0 && max >= 0;

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Text(
            label,
            style: MobileTextStyles.bodyMd(context).copyWith(
              color: MobileColors.onSurface(context),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        MobilePrayerOffsetStepperButton(
          icon: Icons.add_rounded,
          enabled: value < max,
          onStep: () => _step(1),
          color: primary,
        ),
        const SizedBox(width: 6),
        _ValueBadge(
          value: value,
          unit: unit,
          color: value != 0 ? primary : MobileColors.onSurface(context),
          canReset: canReset,
          onReset: _reset,
        ),
        const SizedBox(width: 6),
        MobilePrayerOffsetStepperButton(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onStep: () => _step(-1),
          color: primary,
        ),
      ],
    );
  }
}

class _ValueBadge extends StatelessWidget {
  final int value;
  final String unit;
  final Color color;
  final bool canReset;
  final VoidCallback onReset;

  const _ValueBadge({
    required this.value,
    required this.unit,
    required this.color,
    required this.canReset,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final display = value > 0 ? '+$value' : '$value';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canReset ? onReset : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minWidth: 64),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          alignment: Alignment.center,
          child: Text(
            '$display $unit',
            style: MobileTextStyles.titleMd(context).copyWith(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
