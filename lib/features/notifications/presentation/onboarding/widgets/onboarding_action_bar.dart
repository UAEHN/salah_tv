import 'package:flutter/material.dart';

/// Bottom action area. A subtle text-link "اختبار" sits above the primary
/// "متابعة" pill — when blocked, the pill stays dim and a single muted
/// helper line replaces any red banner.
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

  static const _accent = Color(0xFFE6B450);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canTest) _TestLink(isTesting: isTesting, onTap: onTest),
        // Notifications are optional: never block the user here. When not yet
        // granted we show a soft, skippable hint instead of disabling the
        // button — they can enable later from Settings › صحة الإشعارات.
        if (!canContinue) const _SkipHint(),
        const SizedBox(height: 6),
        _PrimaryButton(enabled: true, onTap: onContinue),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _PrimaryButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: OnboardingActionBar._accent.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: OnboardingActionBar._accent,
          foregroundColor: const Color(0xFF1A1208),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'متابعة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _TestLink extends StatelessWidget {
  final bool isTesting;
  final VoidCallback onTap;
  const _TestLink({required this.isTesting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: isTesting ? null : onTap,
        icon: isTesting
            ? const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(strokeWidth: 1.6),
              )
            : Icon(
                Icons.send_outlined,
                size: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
        label: Text(
          isTesting ? 'جاري الإرسال...' : 'إرسال إشعار تجريبي',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        ),
      ),
    );
  }
}

class _SkipHint extends StatelessWidget {
  const _SkipHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        'يمكنك تفعيل الإشعارات لاحقاً من الإعدادات.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 12,
        ),
      ),
    );
  }
}
