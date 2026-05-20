import 'package:flutter/material.dart';

/// Compact chip showing how many of the core permissions have been granted
/// (e.g. "2 من 3"). Switches to a celebratory "اكتمل" state once everything
/// is green. Sits next to the screen header.
class OnboardingProgressChip extends StatelessWidget {
  final int granted;
  final int total;
  const OnboardingProgressChip({
    super.key,
    required this.granted,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = granted >= total;
    final color = isComplete ? Colors.greenAccent : const Color(0xFFE6B450);
    final label = isComplete ? 'اكتمل ✓' : '$granted من $total';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.verified_rounded : Icons.shield_moon_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
