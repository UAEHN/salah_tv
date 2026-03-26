import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Horizontal progress indicator showing current position in adhkar list.
class MobileAdhkarProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const MobileAdhkarProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (current + 1) / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${current + 1} / $total',
                style: MobileTextStyles.labelSm(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: MobileColors.border(context),
              valueColor: const AlwaysStoppedAnimation<Color>(
                MobileColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
