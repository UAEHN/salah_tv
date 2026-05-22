import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Fixed pointer at the very top of the compass — indicates "where the phone
/// is pointing". Slim, single-tone, follows the active theme accent.
class QiblaCompassPointer extends StatelessWidget {
  final bool isAligned;
  const QiblaCompassPointer({super.key, this.isAligned = false});

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    final brightAccent = MobileColors.activePrimaryContainer(context);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accent, accent.withValues(alpha: 0.0)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            ClipPath(
              clipper: _DownTriangleClipper(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 14,
                height: 10,
                color: isAligned ? brightAccent : accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
