import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Compact toggle row used inside prayer notification cards.
class MobileNotificationToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const MobileNotificationToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              label,
              style: MobileTextStyles.bodyMd(context).copyWith(
                color: MobileColors.onSurfaceMuted(context),
                fontSize: 14,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: value,
              onChanged: isEnabled ? onChanged : null,
              activeTrackColor: MobileColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable chip showing reminder duration with edit icon.
class MobileReminderDurationChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const MobileReminderDurationChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 32, bottom: 6, top: 2),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MobileColors.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MobileColors.primaryContainer.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 13,
                    color: MobileColors.primaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: MobileTextStyles.bodyMd(context).copyWith(
                      color: MobileColors.primaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
