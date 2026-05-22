import 'package:flutter/material.dart';

const _accent = Color(0xFFE6B450);
const _success = Color(0xFF6EE7B7);

/// Trailing slot for [OnboardingPermissionCard]: a "تفعيل" pill until the
/// permission is granted, then a calm check glyph.
class PermissionCardTrailing extends StatelessWidget {
  final bool isGranted;
  final VoidCallback onTap;

  const PermissionCardTrailing({
    super.key,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isGranted) {
      return Icon(
        Icons.check_rounded,
        color: _success.withValues(alpha: 0.95),
        size: 22,
      );
    }
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _accent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: _accent.withValues(alpha: 0.45), width: 1),
        ),
      ),
      child: const Text(
        'تفعيل',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}
