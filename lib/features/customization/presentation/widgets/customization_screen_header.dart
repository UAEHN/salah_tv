import 'package:flutter/material.dart';

import '../../../../core/mobile_theme.dart';

/// Reusable header for customization-feature screens (theme picker, font
/// picker). Mirrors the visual rhythm of `MobileSettingsHeader` so users
/// stay oriented when navigating between settings sub-screens.
class CustomizationScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomizationScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: MobileColors.onSurface(context),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: MobileTextStyles.titleMd(context).copyWith(
                    color: MobileColors.onSurface(context),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: MobileTextStyles.labelSm(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
