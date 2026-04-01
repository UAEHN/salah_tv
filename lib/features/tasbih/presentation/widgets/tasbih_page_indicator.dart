import 'package:flutter/material.dart';
import '../../../../core/mobile_theme.dart';

class TasbihPageIndicator extends StatelessWidget {
  final int total;
  final int current;

  const TasbihPageIndicator({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? MobileColors.primary
                : MobileColors.primary.withValues(alpha: 0.22),
          ),
        );
      }),
    );
  }
}
