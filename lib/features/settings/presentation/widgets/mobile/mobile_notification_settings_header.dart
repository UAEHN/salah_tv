import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileNotificationSettingsHeader extends StatelessWidget {
  const MobileNotificationSettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            'إعدادات التنبيهات',
            style: MobileTextStyles.titleMd(context).copyWith(
              color: MobileColors.onSurface(context),
              fontSize: 24,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: MobileColors.onSurface(context),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
