import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Section heading shown above each group of settings tiles. The icon is
/// rendered in the active theme accent at 70% alpha so it reads as a
/// subtle label rather than a competing accent.
class MobileSettingsSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const MobileSettingsSectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: MobileTextStyles.headlineMd(context).copyWith(
              color: MobileColors.onSurface(context),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            color: MobileColors.activePrimary(context).withValues(alpha: 0.70),
            size: 16,
          ),
        ],
      ),
    );
  }
}
