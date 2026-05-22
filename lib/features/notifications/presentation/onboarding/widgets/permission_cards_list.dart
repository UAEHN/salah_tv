import 'package:flutter/material.dart';

import '../notification_onboarding_cubit.dart';
import '../notification_onboarding_state.dart';
import 'onboarding_permission_card.dart';

/// Numbered list of permission cards. Order matters — index drives the
/// circled step number shown on each tile.
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
    final tiles = <OnboardingPermissionCard>[
      OnboardingPermissionCard(
        step: 1,
        icon: Icons.notifications_none_rounded,
        title: 'إذن الإشعارات',
        description: 'لإظهار إشعارات الأذان والإقامة والأذكار.',
        isGranted: h.postNotifications,
        isRequired: true,
        onTap: cubit.grantNotifications,
      ),
      OnboardingPermissionCard(
        step: 2,
        icon: Icons.access_time_rounded,
        title: 'الإنذارات الدقيقة',
        description: 'ليصل الأذان في وقته بالضبط دون تأخير.',
        isGranted: h.exactAlarm,
        onTap: cubit.grantExactAlarm,
      ),
      OnboardingPermissionCard(
        step: 3,
        icon: Icons.battery_full_rounded,
        title: 'إعفاء من تحسين البطارية',
        description: 'لمنع النظام من إيقاف الإشعارات.',
        isGranted: h.batteryUnrestricted,
        onTap: cubit.grantBattery,
      ),
      if (state.isOemStepRelevant)
        OnboardingPermissionCard(
          step: 4,
          icon: Icons.shield_outlined,
          title: 'حماية ضد قتل التطبيق',
          description: 'فعّل غسق في قائمة التطبيقات النشطة.',
          isGranted: false,
          onTap: cubit.openOemAutostart,
        ),
    ];

    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemCount: tiles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => tiles[i],
    );
  }
}
