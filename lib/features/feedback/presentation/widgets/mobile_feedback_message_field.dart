import 'package:flutter/material.dart';

import '../../../../core/mobile_theme.dart';

class MobileFeedbackMessageField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const MobileFeedbackMessageField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = MobileColors.cardColor(context);

    return Container(
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MobileColors.border(context)),
      ),
      child: TextField(
        controller: controller,
        maxLines: 6,
        minLines: 6,
        textDirection: TextDirection.rtl,
        style: MobileTextStyles.bodyMd(context).copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: MobileTextStyles.bodyMd(
            context,
          ).copyWith(color: MobileColors.onSurfaceFaint(context), fontSize: 14),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
