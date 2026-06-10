import 'package:flutter/material.dart';

import '../../../../core/mobile_theme.dart';

/// Single direct-contact tile (email or Telegram) shown inside the
/// "or contact us directly" section of the mobile feedback form.
class MobileFeedbackContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const MobileFeedbackContactTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: MobileColors.cardColor(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MobileColors.border(context)),
          ),
          child: Row(
            children: [
              Icon(icon, color: MobileColors.activePrimary(context), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: MobileTextStyles.bodyMd(
                        context,
                      ).copyWith(fontSize: 14),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: MobileTextStyles.bodyMd(context).copyWith(
                          color: MobileColors.onSurfaceFaint(context),
                          fontSize: 12,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                color: MobileColors.onSurfaceFaint(context),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
