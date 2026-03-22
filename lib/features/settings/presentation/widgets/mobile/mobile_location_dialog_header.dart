import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

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
    final titleColor = MobileColors.onSurface(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showCities)
                IconButton(
                  onPressed: onBack,
                  icon: Icon(Icons.arrow_back_ios, color: titleColor, size: 20),
                ),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close,
              color: MobileColors.onSurfaceMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}
