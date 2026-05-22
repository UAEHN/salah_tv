import 'package:flutter/material.dart';

const _accent = Color(0xFFE6B450);

/// Primary CTA at the bottom of the language step.
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
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: _PrimaryButton(label: label, onTap: onTap, isLoading: false),
      ),
    );
  }
}

/// Primary CTA shown on the city step once a city has been selected.
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
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.20),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: isVisible
          ? Padding(
              key: const ValueKey('finish_btn'),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: _PrimaryButton(
                label: label,
                onTap: isLoading ? null : onTap,
                isLoading: isLoading,
              ),
            )
          : const SizedBox(key: ValueKey('finish_empty'), height: 8),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.32),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: const Color(0xFF1A1208),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF1A1208),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
