import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';

/// Master on/off "hero" card for prayer adhan sound. When ON, the card lights
/// up with the live accent gradient to signal that the prayer cycle is armed.
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
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final accentSoft = MobileColors.activePrimaryContainer(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: isOn
            ? LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [accent, accentSoft],
              )
            : null,
        color: isOn
            ? null
            : MobileColors.cardColor(context).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isOn
              ? Colors.transparent
              : MobileColors.border(context).withValues(alpha: 0.7),
        ),
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.30),
                  offset: const Offset(0, 10),
                  blurRadius: 24,
                ),
              ]
            : MobileShadows.sleekCard(context),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _HeroIcon(isOn: isOn),
          const SizedBox(width: 14),
          Expanded(
            child: _HeroText(isOn: isOn, l: l),
          ),
          Switch.adaptive(
            value: isOn,
            onChanged: onChanged,
            activeTrackColor: Colors.white.withValues(alpha: 0.45),
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  final bool isOn;
  const _HeroIcon({required this.isOn});

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isOn
            ? Colors.white.withValues(alpha: 0.22)
            : accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(
        isOn
            ? Icons.notifications_active_rounded
            : Icons.notifications_off_rounded,
        color: isOn ? Colors.white : MobileColors.onSurfaceMuted(context),
        size: 22,
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  final bool isOn;
  final AppLocalizations l;
  const _HeroText({required this.isOn, required this.l});

  @override
  Widget build(BuildContext context) {
    final titleColor = isOn ? Colors.white : MobileColors.onSurface(context);
    final subColor = isOn
        ? Colors.white.withValues(alpha: 0.78)
        : MobileColors.onSurfaceMuted(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isOn
              ? l.settingsNotificationsEnabled
              : l.settingsNotificationsDisabled,
          style: MobileTextStyles.headlineMd(
            context,
          ).copyWith(color: titleColor, fontSize: 16, height: 1.15),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 3),
        Text(
          isOn
              ? 'سيتم تشغيل صوت الأذان لكل صلاة'
              : 'لا يصدر صوت أذان عند دخول وقت الصلاة',
          style: MobileTextStyles.bodyMd(
            context,
          ).copyWith(color: subColor, fontSize: 11.5, height: 1.3),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
