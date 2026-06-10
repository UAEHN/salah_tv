import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_health.dart';
import '../../domain/usecases/get_notification_health.dart';
import '../../domain/usecases/open_permission_settings.dart';
import '../../domain/usecases/run_notification_test.dart';
import 'notification_health_state.dart';

/// Holds the notification health snapshot for the diagnostic screen and
/// orchestrates the user-triggered remediation actions through use-cases —
/// no direct port dependency, per the use-case-per-boundary rule.
class NotificationHealthCubit extends Cubit<NotificationHealthState> {
  final GetNotificationHealth _getHealth;
  final RunNotificationTest _runTest;
  final OpenNotificationSettings _openNotifSettings;
  final OpenExactAlarmSettings _openExactAlarm;
  final OpenBatteryOptimizationSettings _openBattery;
  final OpenOemAutostart _openOem;

  NotificationHealthCubit({
    required GetNotificationHealth getHealth,
    required RunNotificationTest runTest,
    required OpenNotificationSettings openNotifSettings,
    required OpenExactAlarmSettings openExactAlarm,
    required OpenBatteryOptimizationSettings openBattery,
    required OpenOemAutostart openOem,
  }) : _getHealth = getHealth,
       _runTest = runTest,
       _openNotifSettings = openNotifSettings,
       _openExactAlarm = openExactAlarm,
       _openBattery = openBattery,
       _openOem = openOem,
       super(const NotificationHealthState.initial());

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final res = await _getHealth();
    res.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (h) => _emitHealth(h),
    );
  }

  void _emitHealth(NotificationHealth h) =>
      emit(state.copyWith(health: h, isLoading: false));

  Future<void> runTest() async {
    emit(state.copyWith(isTestPending: true, clearError: true));
    await _runTest();
    emit(state.copyWith(isTestPending: false));
  }

  Future<void> openOemAutostart() => _openOem();
  Future<void> openExactAlarmSettings() => _openExactAlarm();
  Future<void> openNotificationSettings() => _openNotifSettings();
  Future<void> openBatteryOptimizationSettings() => _openBattery();
}
