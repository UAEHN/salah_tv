import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../core/brand_colors.dart';

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
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: entranceAnimation,
            curve: Curves.easeOutCubic,
          ),
        );
    final fadeAnim = CurvedAnimation(
      parent: entranceAnimation,
      curve: Curves.easeOut,
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected
                  ? brandGold.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected
                    ? brandGold
                    : Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: brandGold.withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? brandGold
                            : Colors.white.withValues(alpha: 0.5),
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nativeLabel,
                              style: TextStyle(
                                color: isSelected
                                    ? brandGold
                                    : Colors.white.withValues(alpha: 0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              label,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? brandGold : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? brandGold
                                : Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 13,
                              )
                            : null,
                      ),
                    ],
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
