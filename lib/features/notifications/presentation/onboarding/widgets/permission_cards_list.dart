import 'package:flutter/material.dart';

import '../notification_onboarding_cubit.dart';
import '../notification_onboarding_state.dart';
import 'onboarding_permission_card.dart';

/// Vertical stack of all permission cards shown in the onboarding. Pulled
/// out of the screen file so each layer stays under the 150-line cap
/// (CLAUDE.md §4) and the screen reads as a high-level composition.
class PermissionCardsList extends StatelessWidget {
  final NotificationOnboardingState state;
  final NotificationOnboardingCubit cubit;

  const PermissionCardsList({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final h = state.health;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        OnboardingPermissionCard(
          icon: Icons.notifications_outlined,
          iconColor: const Color(0xFF7AB0FF),
          title: 'إذن الإشعارات',
          description: 'لإظهار إشعارات الأذان والإقامة والأذكار على شاشتك.',
          isGranted: h.postNotifications,
          isRequired: true,
          onTap: cubit.grantNotifications,
        ),
        OnboardingPermissionCard(
          icon: Icons.access_alarm_rounded,
          iconColor: const Color(0xFFFFB266),
          title: 'الإنذارات الدقيقة',
          description: 'ليصل الأذان في وقته بالضبط دون تأخير من النظام.',
          isGranted: h.exactAlarm,
          onTap: cubit.grantExactAlarm,
        ),
        OnboardingPermissionCard(
          icon: Icons.battery_charging_full_rounded,
          iconColor: const Color(0xFF6EE7B7),
          title: 'إعفاء من تحسين البطارية',
          description: 'لمنع النظام من إيقاف الإشعارات لتوفير البطارية.',
          isGranted: h.batteryUnrestricted,
          onTap: cubit.grantBattery,
        ),
        if (state.isOemStepRelevant)
          OnboardingPermissionCard(
            icon: Icons.shield_rounded,
            iconColor: const Color(0xFFFF8A65),
            title: 'حماية ضد قتل التطبيق',
            description: 'هاتفك يُغلق التطبيقات تلقائيًا — فعّل غسق في القائمة.',
            isGranted: false,
            onTap: cubit.openOemAutostart,
          ),
      ],
    );
  }
}
