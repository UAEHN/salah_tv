import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/settings_provider.dart';

class TopBar extends StatelessWidget {
  final AccentPalette palette;

  const TopBar({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: screenH * 0.012),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: palette.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mosque_rounded,
            color: palette.primary.withValues(alpha: 0.8),
            size: screenH * 0.038,
          ),
          const SizedBox(width: 10),
          Text(
            'مواقيت الصلاة',
            style: TextStyle(
              fontSize: screenH * 0.042,
              fontWeight: FontWeight.w700,
              color: tc.textPrimary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
