import 'package:flutter/material.dart';

/// Hero header for the notification onboarding. Large monochrome glyph in a
/// soft glass capsule, refined typography below, and a thin progress bar
/// instead of a colored chip. Designed to feel like the start of a calm
/// premium flow rather than a checklist.
class OnboardingHeader extends StatelessWidget {
  final int granted;
  final int total;

  const OnboardingHeader({
    super.key,
    required this.granted,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = granted >= total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _HeroGlyph(),
            const Spacer(),
            Text(
              isComplete ? 'اكتمل' : '$granted / $total',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: isComplete
                    ? const Color(0xFF6EE7B7).withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'تنبيهات الصلاة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'فعّل الأذونات التالية ليصل الأذان في وقته بالضبط.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13.5,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        _ProgressBar(granted: granted, total: total),
      ],
    );
  }
}

class _HeroGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.notifications_none_rounded,
        size: 28,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int granted;
  final int total;
  const _ProgressBar({required this.granted, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : (granted / total).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, c) {
        return Stack(
          children: [
            Container(
              height: 4,
              width: c.maxWidth,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              height: 4,
              width: c.maxWidth * fraction,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6B450), Color(0xFFF0CD7A)],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        );
      },
    );
  }
}
