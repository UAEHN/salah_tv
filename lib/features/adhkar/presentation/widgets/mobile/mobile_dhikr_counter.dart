import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Circular tap-to-decrement counter button.
class MobileDhikrCounter extends StatelessWidget {
  final int remaining;
  final int total;
  final bool isCompleted;
  final VoidCallback onTap;

  const MobileDhikrCounter({
    super.key,
    required this.remaining,
    required this.total,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (total - remaining) / total : 1.0;

    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 88,
              height: 88,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: MobileColors.border(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : MobileColors.primary,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCompleted)
                  Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                    size: 32,
                  )
                else ...[
                  Text(
                    '$remaining',
                    style: MobileTextStyles.titleMd(context).copyWith(
                      color: MobileColors.primary,
                      fontSize: 28,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
