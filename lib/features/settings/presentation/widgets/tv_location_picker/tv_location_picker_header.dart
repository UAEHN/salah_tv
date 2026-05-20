import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_colors.dart';
import '../../settings_provider.dart';

class TvLocationPickerHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback onBack;

  const TvLocationPickerHeader({
    required this.title,
    required this.showBack,
    required this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back_rounded, color: tc.textPrimary),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tc.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: tc.textSecondary),
          ),
        ],
      ),
    );
  }
}
