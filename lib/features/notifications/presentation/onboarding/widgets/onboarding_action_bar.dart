import 'package:flutter/material.dart';

/// Bottom button stack for the notification onboarding screen. Shows a
/// secondary "اختبر إشعارًا" trigger (visible once the basic notifications
/// permission is granted) and a primary "متابعة" button — the latter is
/// disabled until the mandatory permission is in place, with a friendly
/// hint replacing the spacing instead of a raw error.
class OnboardingActionBar extends StatelessWidget {
  final bool canContinue;
  final bool canTest;
  final bool isTesting;
  final VoidCallback onTest;
  final VoidCallback onContinue;

  const OnboardingActionBar({
    super.key,
    required this.canContinue,
    required this.canTest,
    required this.isTesting,
    required this.onTest,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canTest) _TestButton(isTesting: isTesting, onTap: onTest),
        if (canTest) const SizedBox(height: 10),
        if (!canContinue) _BlockedHint(),
        FilledButton(
          onPressed: canContinue ? onContinue : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE6B450),
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.45),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'متابعة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _TestButton extends StatelessWidget {
  final bool isTesting;
  final VoidCallback onTap;
  const _TestButton({required this.isTesting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isTesting ? null : onTap,
      icon: isTesting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.send_rounded, size: 18),
      label: Text(
        isTesting ? 'جاري الإرسال...' : 'اختبر إشعارًا تجريبيًا (15 ثانية)',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.32)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _BlockedHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.40),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'فعّل إذن الإشعارات أولًا لتتمكن من المتابعة.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
