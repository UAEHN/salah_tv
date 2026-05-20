import 'package:flutter/material.dart';

import 'permission_card_texts.dart';

/// One row in the notification onboarding. Shows an icon, label, why-line,
/// and either a green check (if granted) or a "تفعيل" button. Designed
/// for the dark animated background, so all colors are picked for contrast.
class OnboardingPermissionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isGranted;
  final bool isRequired;
  final VoidCallback onTap;

  const OnboardingPermissionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onTap,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isGranted
        ? Colors.greenAccent.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.10);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isGranted ? 0.07 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isGranted ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: PermissionCardTexts(
                    title: title,
                    description: description,
                    isRequired: isRequired,
                  ),
                ),
                const SizedBox(width: 8),
                _Trailing(isGranted: isGranted, onTap: onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Trailing extends StatelessWidget {
  final bool isGranted;
  final VoidCallback onTap;
  const _Trailing({required this.isGranted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isGranted) {
      return const Icon(Icons.check_circle_rounded,
          color: Colors.greenAccent, size: 28);
    }
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFE6B450).withValues(alpha: 0.22),
        foregroundColor: const Color(0xFFE6B450),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text('تفعيل', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
