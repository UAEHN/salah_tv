import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

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
      padding: const EdgeInsets.only(bottom: 12, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: MobileTextStyles.headlineMd(
              context,
            ).copyWith(color: MobileColors.onSurface(context), fontSize: 16),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: MobileColors.primaryContainer, size: 20),
        ],
      ),
    );
  }
}
