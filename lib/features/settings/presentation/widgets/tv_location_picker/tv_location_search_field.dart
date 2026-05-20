import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_colors.dart';
import '../../settings_provider.dart';

class TvLocationSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const TvLocationSearchField({
    required this.hintText,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final accent = getThemePalette(settings.themeColorKey).primary;
    final isDark = tc.isDark;
    final fill = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    return TextField(
      onChanged: onChanged,
      style: TextStyle(color: tc.textPrimary, fontSize: 18),
      cursorColor: accent,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: tc.textMuted),
        prefixIcon: Icon(Icons.search_rounded, color: tc.textSecondary),
        filled: true,
        fillColor: fill,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}
