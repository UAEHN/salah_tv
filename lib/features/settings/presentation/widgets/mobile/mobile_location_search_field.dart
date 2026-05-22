import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileLocationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClearIcon;

  const MobileLocationSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.showClearIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    final accent = MobileColors.activePrimary(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.search,
        cursorColor: accent,
        style: TextStyle(
          color: MobileColors.onSurface(context),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: MobileColors.onSurfaceMuted(context).withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: MobileColors.onSurfaceMuted(context),
            size: 20,
          ),
          suffixIcon: !showClearIcon || controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: MobileColors.onSurfaceMuted(context),
                    size: 18,
                  ),
                ),
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: MobileColors.border(context),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: accent.withValues(alpha: 0.55),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
