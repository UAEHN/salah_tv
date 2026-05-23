import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Single-line reminder row for the daily-reminder sections (morning adhkar,
/// evening adhkar, Surat Al-Kahf). RTL layout: [switch] [time chip when on]
/// [label] [leading icon]. Putting the chip inline removes the awkward second
/// row the old design had and keeps each reminder visually self-contained.
class MobileNotificationReminderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final int minuteOfDay;
  final String pickerTitle;
  final ValueChanged<bool> onChanged;
  final ValueChanged<int> onPickTime;
  final bool showDivider;

  const MobileNotificationReminderRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isOn,
    required this.minuteOfDay,
    required this.pickerTitle,
    required this.onChanged,
    required this.onPickTime,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(textDirection: TextDirection.rtl, children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isOn ? 0.18 : 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: MobileTextStyles.bodyMd(context).copyWith(
                color: MobileColors.onSurface(context),
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          if (isOn) ...[
            _InlineTimeChip(
              minuteOfDay: minuteOfDay,
              pickerTitle: pickerTitle,
              onPick: onPickTime,
            ),
            const SizedBox(width: 6),
          ],
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: isOn,
              onChanged: onChanged,
              activeTrackColor: MobileColors.primaryContainer,
            ),
          ),
        ]),
      ),
      if (showDivider)
        Divider(
          height: 1,
          thickness: 1,
          color: MobileColors.border(context).withValues(alpha: 0.6),
        ),
    ]);
  }
}

class _InlineTimeChip extends StatelessWidget {
  final int minuteOfDay;
  final String pickerTitle;
  final ValueChanged<int> onPick;
  const _InlineTimeChip({
    required this.minuteOfDay,
    required this.pickerTitle,
    required this.onPick,
  });

  Future<void> _open(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: minuteOfDay ~/ 60,
        minute: minuteOfDay % 60,
      ),
      helpText: pickerTitle,
    );
    if (picked != null) onPick(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    final hh = (minuteOfDay ~/ 60).toString().padLeft(2, '0');
    final mm = (minuteOfDay % 60).toString().padLeft(2, '0');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.access_time_rounded, size: 13, color: accent),
            const SizedBox(width: 5),
            Text(
              '$hh:$mm',
              style: TextStyle(
                color: accent,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
