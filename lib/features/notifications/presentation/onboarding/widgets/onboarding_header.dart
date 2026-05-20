import 'package:flutter/material.dart';

/// Title + subtitle banner shown at the top of the notification onboarding
/// screen. Now sits over a dark animated background, so colors are tuned
/// for contrast on `#050A18`. The optional [trailing] slot hosts the
/// progress chip without breaking the 150-line cap (CLAUDE.md §4).
class OnboardingHeader extends StatelessWidget {
  final Widget? trailing;
  const OnboardingHeader({super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE6B450).withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE6B450).withValues(alpha: 0.45),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 28,
                color: Color(0xFFE6B450),
              ),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'فعّل تنبيهات الأذان',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'حتى لا تفوتك صلاة — هذه الأذونات تجعل الإشعار يصل في وقته بالضبط.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 13.5,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}
