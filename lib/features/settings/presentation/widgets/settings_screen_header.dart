import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

/// Top gradient header bar for the settings screen.
class SettingsScreenHeader extends StatelessWidget {
  final AccentPalette palette;

  const SettingsScreenHeader({required this.palette, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        gradient: palette.gradient,
        boxShadow: [
          BoxShadow(
            color: palette.glow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white70,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
