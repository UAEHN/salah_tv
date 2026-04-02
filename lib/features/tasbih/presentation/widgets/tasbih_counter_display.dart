import 'package:flutter/material.dart';
import '../../../../core/mobile_theme.dart';

class TasbihCounterDisplay extends StatelessWidget {
  final int count;
  final int target;
  final bool isCompleted;
  final VoidCallback? onTap;

  const TasbihCounterDisplay({
    super.key,
    required this.count,
    required this.target,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (count / target).clamp(0.0, 1.0);
    final color = isCompleted
        ? MobileColors.primaryContainer
        : MobileColors.primary;

    final size = (MediaQuery.of(context).size.height * 0.30).clamp(
      160.0,
      260.0,
    );
    final innerSize = size * (216 / 260);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.07),
                  border: Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Text(
                        '$count',
                        key: ValueKey(count),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: color,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '/ $target',
                      style: TextStyle(
                        fontSize: 18,
                        color: color.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
