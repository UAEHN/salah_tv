import 'package:flutter/material.dart';

const _accent = Color(0xFFE6B450);

/// Single language pick row in the welcome step. Matches the country/city
/// tile aesthetic — same rounded card, same accent treatment — so the
/// onboarding feels like one coherent flow.
class OnboardingLanguageCard extends StatelessWidget {
  final String locale;
  final String label;
  final String nativeLabel;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double> entranceAnimation;

  const OnboardingLanguageCard({
    super.key,
    required this.locale,
    required this.label,
    required this.nativeLabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.entranceAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
      CurvedAnimation(parent: entranceAnimation, curve: Curves.easeOutCubic),
    );
    final fadeAnim = CurvedAnimation(
      parent: entranceAnimation,
      curve: Curves.easeOut,
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _accent.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? _accent.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? _accent
                          : Colors.white.withValues(alpha: 0.75),
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nativeLabel,
                            style: TextStyle(
                              color: isSelected ? _accent : Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_rounded, color: _accent, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
