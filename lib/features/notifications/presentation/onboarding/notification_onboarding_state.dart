import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_health.dart';

@immutable
class NotificationOnboardingState {
  final NotificationHealth health;
  final bool isLoading;
  final bool isTesting;

  const NotificationOnboardingState({
    required this.health,
    required this.isLoading,
    required this.isTesting,
  });

  const NotificationOnboardingState.initial()
      : health = NotificationHealth.empty,
        isLoading = true,
        isTesting = false;

  NotificationOnboardingState copyWith({
    NotificationHealth? health,
    bool? isLoading,
    bool? isTesting,
  }) =>
      NotificationOnboardingState(
        health: health ?? this.health,
        isLoading: isLoading ?? this.isLoading,
        isTesting: isTesting ?? this.isTesting,
      );

  bool get isOemStepRelevant => health.oem.needsAttention;

  /// Notifications is the only mandatory permission — without it the engine
  /// cannot fire anything. Exact-alarm + battery are quality boosters.
  bool get canContinue => health.postNotifications;

  bool get hasAllCorePermissions =>
      health.postNotifications &&
      health.exactAlarm &&
      health.batteryUnrestricted;

  int get coreGrantedCount {
    var n = 0;
    if (health.postNotifications) n++;
    if (health.exactAlarm) n++;
    if (health.batteryUnrestricted) n++;
    return n;
  }

  int get coreTotalCount => 3;
}
