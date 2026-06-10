import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';

class MobileNotificationSettingsHeader extends StatelessWidget {
  const MobileNotificationSettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final onSurface = MobileColors.onSurface(context);
    final muted = MobileColors.onSurfaceMuted(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BackButton(color: onSurface),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.settingsNotificationSettings,
                  style: MobileTextStyles.titleMd(
                    context,
                  ).copyWith(color: onSurface, fontSize: 22, height: 1.1),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 2),
                Text(
                  'الأذكار والأذان والتذكير الأسبوعي',
                  style: MobileTextStyles.bodyMd(
                    context,
                  ).copyWith(color: muted, fontSize: 12.5),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _HeaderBellBadge(),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final Color color;
  const _BackButton({required this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_forward_rounded, color: color),
      onPressed: () => Navigator.pop(context),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}

class _HeaderBellBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.notifications_active_rounded, color: accent, size: 20),
    );
  }
}
