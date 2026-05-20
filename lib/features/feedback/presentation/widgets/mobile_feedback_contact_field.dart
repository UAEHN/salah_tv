import 'package:flutter/material.dart';

import '../../../../core/mobile_theme.dart';

class MobileFeedbackContactField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  /// Optional inline error shown below the field (red text + red border).
  /// Pass `null` (the default) to render the field in its normal state.
  final String? errorText;

  const MobileFeedbackContactField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = MobileColors.cardColor(context);
    final hasError = errorText != null;
    final borderColor =
        hasError ? Colors.redAccent : MobileColors.border(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: MobileTextStyles.bodyMd(context).copyWith(
            color: MobileColors.onSurfaceMuted(context),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.emailAddress,
            style: MobileTextStyles.bodyMd(context).copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: MobileTextStyles.bodyMd(context).copyWith(
                color: MobileColors.onSurfaceFaint(context),
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: MobileTextStyles.bodyMd(context).copyWith(
              color: Colors.redAccent,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
