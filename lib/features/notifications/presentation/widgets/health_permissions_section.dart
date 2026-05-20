import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/notification_health_cubit.dart';
import '../cubit/notification_health_state.dart';
import 'health_status_tile.dart';

/// Renders the three permission tiles for the notification health screen
/// and wires their action buttons to the cubit. Pulled out of the screen
/// so the screen file stays under the 150-line cap.
class HealthPermissionsSection extends StatelessWidget {
  final NotificationHealthState state;
  const HealthPermissionsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationHealthCubit>();
    final h = state.health;
    return Column(
      children: [
        HealthStatusTile(
          title: 'إذن الإشعارات',
          subtitle: h.postNotifications ? 'مفعّل' : 'مطلوب لإظهار الإشعارات',
          isOk: h.postNotifications,
          actionLabel: 'فتح الإعدادات',
          onAction: cubit.openNotificationSettings,
        ),
        HealthStatusTile(
          title: 'الإنذارات الدقيقة (Exact Alarm)',
          subtitle: h.exactAlarm
              ? 'مفعّل — الأذان في وقته بالضبط'
              : 'يجب تفعيله ليصل الأذان في الوقت',
          isOk: h.exactAlarm,
          actionLabel: 'فتح الإعدادات',
          onAction: cubit.openExactAlarmSettings,
        ),
        HealthStatusTile(
          title: 'إعفاء من تحسين البطارية',
          subtitle: h.batteryUnrestricted
              ? 'مفعّل — لن يُؤخّر النظام الإشعارات'
              : 'بدونه قد يتأخر الأذان حتى 9 دقائق',
          isOk: h.batteryUnrestricted,
          actionLabel: 'طلب الإعفاء',
          onAction: cubit.openBatteryOptimizationSettings,
        ),
      ],
    );
  }
}
