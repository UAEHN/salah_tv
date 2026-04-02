import 'package:flutter/material.dart';

import '../../../../core/brand_colors.dart';

class OnboardingNextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Animation<double> entranceAnimation;

  const OnboardingNextButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.entranceAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnim = CurvedAnimation(
      parent: entranceAnimation,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: _GoldenButton(label: label, onTap: onTap, isLoading: false),
      ),
    );
  }
}

class OnboardingFinishButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isVisible;

  const OnboardingFinishButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.isLoading,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: Tween(begin: 0.85, end: 1.0).animate(anim),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: isVisible
          ? Padding(
              key: const ValueKey('finish_btn'),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: _GoldenButton(
                label: label,
                onTap: isLoading ? null : onTap,
                isLoading: isLoading,
              ),
            )
          : const SizedBox(key: ValueKey('finish_empty'), height: 8),
    );
  }
}

class _GoldenButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _GoldenButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [brandGold, brandGoldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: brandGold.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
