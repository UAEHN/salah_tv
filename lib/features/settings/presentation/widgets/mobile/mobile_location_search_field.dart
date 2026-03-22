import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileLocationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const MobileLocationSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.search,
        style: MobileTextStyles.bodyMd(
          context,
        ).copyWith(color: MobileColors.onSurface(context), fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: MobileTextStyles.bodyMd(context),
          prefixIcon: Icon(
            Icons.search,
            color: MobileColors.onSurfaceMuted(context),
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close,
                    color: MobileColors.onSurfaceMuted(context),
                  ),
                ),
          filled: true,
          fillColor: MobileColors.cardColor(context).withValues(alpha: 0.55),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: MobileColors.border(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: MobileColors.primary.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}
