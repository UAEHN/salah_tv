import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

/// Master on/off toggle card for all notifications.
class MobileNotificationMasterToggle extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const MobileNotificationMasterToggle({
    super.key,
    required this.isOn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = MobileColors.cardColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MobileColors.border(context).withValues(alpha: 0.7),
        ),
        boxShadow: MobileShadows.sleekCard(context),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            isOn
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            color: isOn
                ? MobileColors.primaryContainer
                : MobileColors.onSurfaceMuted(context),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isOn ? 'الإشعارات مفعّلة' : 'الإشعارات معطّلة',
              style: MobileTextStyles.titleMd(context).copyWith(
                color: MobileColors.onSurface(context),
                fontSize: 16,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Switch.adaptive(
            value: isOn,
            onChanged: onChanged,
            activeTrackColor: MobileColors.primaryContainer,
          ),
        ],
      ),
    );
  }
}
