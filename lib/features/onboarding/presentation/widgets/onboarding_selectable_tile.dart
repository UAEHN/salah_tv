import 'package:flutter/material.dart';

const _accent = Color(0xFFE6B450);

/// Selectable country / city row in the onboarding list. Renders as a thin
/// rounded card with a subtle border so the list reads as a sequence of
/// chips rather than bare ListTile rows. The selected row is highlighted
/// with a soft gold tint.
class OnboardingSelectableTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const OnboardingSelectableTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? _accent.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? _accent.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: isSelected ? _accent : Colors.white,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_rounded, color: _accent, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
