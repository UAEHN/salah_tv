import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Compact "HH:MM" chip used by notification sections to pick the wall-clock
/// time of a recurring reminder. Tapping opens the platform time picker;
/// confirmation invokes [onPick] with the new minute-of-day (0..1439).
class MobileNotificationTimeChip extends StatelessWidget {
  final int minuteOfDay;
  final ValueChanged<int> onPick;
  final String pickerTitle;

  const MobileNotificationTimeChip({
    super.key,
    required this.minuteOfDay,
    required this.onPick,
    required this.pickerTitle,
  });

  @override
  Widget build(BuildContext context) {
    final hh = minuteOfDay ~/ 60;
    final mm = minuteOfDay % 60;
    final label =
        '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(right: 32, bottom: 6, top: 2),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _open(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MobileColors.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MobileColors.primaryContainer.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: MobileColors.primaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: MobileTextStyles.bodyMd(context).copyWith(
                      color: MobileColors.primaryContainer,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60),
      helpText: pickerTitle,
    );
    if (picked != null) onPick(picked.hour * 60 + picked.minute);
  }
}
