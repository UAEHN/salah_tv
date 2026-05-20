import 'package:flutter/material.dart';

import '../../mobile_theme.dart';

/// Single tab inside [MobileBottomNav]: glow-circle icon + label.
///
/// The label is wrapped in a [FittedBox] with `BoxFit.scaleDown` plus
/// `softWrap: false` and `overflow: TextOverflow.visible` so wider fonts
/// (e.g. Rubik) shrink to fit instead of being ellipsised.
class MobileBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const MobileBottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    final muted = MobileColors.onSurfaceMuted(context);
    final fg = isActive ? accent : muted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _IconDisc(icon: icon, accent: accent, isActive: isActive, fg: fg),
          const SizedBox(height: 3),
          _NavLabel(label: label, isActive: isActive, fg: fg),
        ],
      ),
    );
  }
}

class _IconDisc extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final bool isActive;
  final Color fg;

  const _IconDisc({
    required this.icon,
    required this.accent,
    required this.isActive,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? accent.withValues(alpha: 0.16) : Colors.transparent,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.32),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Icon(icon, size: 22, color: fg),
    );
  }
}

class _NavLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color fg;

  const _NavLabel({
    required this.label,
    required this.isActive,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: MobileTextStyles.labelSm(context).copyWith(
          fontSize: 10.5,
          color: fg,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.2,
        ),
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}
