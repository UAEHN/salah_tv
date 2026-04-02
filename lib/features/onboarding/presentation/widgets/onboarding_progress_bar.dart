import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../core/brand_colors.dart';

class OnboardingProgressBar extends StatelessWidget {
  final int currentStep; // 0, 1, 2
  final Animation<double> shimmerAnimation;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [
      l.onboardingStepLanguage,
      l.onboardingStepLocation,
      l.onboardingStepCity,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            _StepDot(
              index: i,
              currentStep: currentStep,
              label: labels[i],
              shimmerAnimation: shimmerAnimation,
            ),
            if (i < 2)
              Expanded(child: _StepConnector(isCompleted: currentStep > i)),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int currentStep;
  final String label;
  final Animation<double> shimmerAnimation;

  const _StepDot({
    required this.index,
    required this.currentStep,
    required this.label,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentStep;
    final isDone = index < currentStep;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: shimmerAnimation,
          builder: (_, _) {
            final pulse = isActive
                ? 0.6 +
                      (shimmerAnimation.value < 0.5
                          ? shimmerAnimation.value * 0.8
                          : (1 - shimmerAnimation.value) * 0.8)
                : 1.0;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              width: isActive ? 36 : 28,
              height: isActive ? 36 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isActive || isDone)
                    ? brandGold.withValues(alpha: pulse)
                    : Colors.transparent,
                border: Border.all(
                  color: (isActive || isDone)
                      ? brandGold
                      : brandGold.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: brandGold.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: (isActive || isDone)
                              ? Colors.white
                              : brandGold.withValues(alpha: 0.6),
                          fontSize: isActive ? 14 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            color: isActive ? brandGold : brandGold.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isCompleted;
  const _StepConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isCompleted ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      builder: (_, value, _) => Stack(
        children: [
          Container(height: 1.5, color: brandGold.withValues(alpha: 0.15)),
          FractionallySizedBox(
            widthFactor: value,
            child: Container(
              height: 1.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [brandGold, brandGoldDark]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
