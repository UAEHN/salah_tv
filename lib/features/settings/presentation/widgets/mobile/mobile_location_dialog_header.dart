import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Bottom-sheet header: thin drag handle, optional back arrow, centered
/// title, and a soft close button. Theme-aware.
class MobileLocationDialogHeader extends StatelessWidget {
  final bool showCities;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const MobileLocationDialogHeader({
    super.key,
    required this.showCities,
    required this.title,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = MobileColors.onSurface(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 14),
          child: Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: MobileColors.onSurfaceMuted(context)
                  .withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(
            children: [
              _CircleButton(
                icon: Icons.close_rounded,
                onTap: onClose,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              showCities
                  ? _CircleButton(
                      icon: Icons.arrow_forward_rounded,
                      onTap: onBack,
                    )
                  : const SizedBox(width: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MobileColors.isDark(context)
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: MobileColors.onSurface(context).withValues(alpha: 0.85),
            size: 20,
          ),
        ),
      ),
    );
  }
}
