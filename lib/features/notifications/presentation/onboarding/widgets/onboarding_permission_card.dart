import 'package:flutter/material.dart';

import 'permission_card_texts.dart';
import 'permission_card_trailing.dart';

const _success = Color(0xFF6EE7B7);

/// One permission tile in the redesigned onboarding. Layout:
/// `[ ① ]  [ icon ]  title + description  [ button / check ]`
/// A leading numbered badge anchors the step and the trailing slot is the
/// only thing that shifts when the permission flips to granted.
class OnboardingPermissionCard extends StatelessWidget {
  final int step;
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final bool isRequired;
  final VoidCallback onTap;

  const OnboardingPermissionCard({
    super.key,
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onTap,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = isGranted
        ? _success.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.04);
    final borderColor = isGranted
        ? _success.withValues(alpha: 0.30)
        : Colors.white.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isGranted ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              _StepBadge(step: step, isGranted: isGranted),
              const SizedBox(width: 12),
              Icon(
                icon,
                size: 22,
                color: Colors.white.withValues(
                  alpha: isGranted ? 0.55 : 0.85,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PermissionCardTexts(
                  title: title,
                  description: description,
                  isRequired: isRequired,
                ),
              ),
              const SizedBox(width: 8),
              PermissionCardTrailing(isGranted: isGranted, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int step;
  final bool isGranted;
  const _StepBadge({required this.step, required this.isGranted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isGranted
            ? _success.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.07),
      ),
      child: Text(
        '$step',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          color: isGranted
              ? _success.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.65),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
