import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/i_notification_onboarding_flag_port.dart';
import '../../domain/usecases/get_notification_health.dart';
import '../../domain/usecases/open_permission_settings.dart';
import '../../domain/usecases/run_notification_test.dart';
import 'notification_onboarding_state.dart';

/// Drives the single-screen notification onboarding. Loads a health
/// snapshot up-front, refreshes it whenever the user comes back from a
/// system settings page, and exposes per-permission grant actions, a
/// "test notification" hook, plus a "done" gate to flip the persisted flag.
///
/// Depends only on use-cases + the flag port (notifications/domain) — never
/// touches the platform channel layer or the settings presentation layer.
class NotificationOnboardingCubit extends Cubit<NotificationOnboardingState> {
  final GetNotificationHealth _getHealth;
  final RequestPostNotifications _requestNotifications;
  final OpenExactAlarmSettings _openExactAlarm;
  final OpenBatteryOptimizationSettings _openBattery;
  final OpenOemAutostart _openOem;
  final RunNotificationTest _runTest;
  final INotificationOnboardingFlagPort _flag;

  NotificationOnboardingCubit({
    required GetNotificationHealth getHealth,
    required RequestPostNotifications requestNotifications,
    required OpenExactAlarmSettings openExactAlarm,
    required OpenBatteryOptimizationSettings openBattery,
    required OpenOemAutostart openOem,
    required RunNotificationTest runTest,
    required INotificationOnboardingFlagPort flag,
  }) : _getHealth = getHealth,
       _requestNotifications = requestNotifications,
       _openExactAlarm = openExactAlarm,
       _openBattery = openBattery,
       _openOem = openOem,
       _runTest = runTest,
       _flag = flag,
       super(const NotificationOnboardingState.initial());

  Future<void> start() => _refresh();

  Future<void> refreshHealth() => _refresh();

  Future<void> _refresh() async {
    final res = await _getHealth();
    res.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (h) => emit(state.copyWith(health: h, isLoading: false)),
    );
  }

  Future<void> grantNotifications() async {
    await _requestNotifications();
    await _refresh();
  }

  Future<void> grantExactAlarm() => _openExactAlarm();
  Future<void> grantBattery() => _openBattery();
  Future<void> openOemAutostart() => _openOem();

  Future<void> runTest() async {
    if (state.isTesting) return;
    emit(state.copyWith(isTesting: true));
    await _runTest();
    emit(state.copyWith(isTesting: false));
  }

  Future<void> markDone() => _flag.markDone();
}
