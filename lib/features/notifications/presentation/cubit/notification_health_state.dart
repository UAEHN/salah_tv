import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_health.dart';

@immutable
class NotificationHealthState {
  final NotificationHealth health;
  final bool isLoading;
  final bool isTestPending;
  final String? error;

  const NotificationHealthState({
    required this.health,
    required this.isLoading,
    required this.isTestPending,
    required this.error,
  });

  const NotificationHealthState.initial()
      : health = NotificationHealth.empty,
        isLoading = true,
        isTestPending = false,
        error = null;

  NotificationHealthState copyWith({
    NotificationHealth? health,
    bool? isLoading,
    bool? isTestPending,
    String? error,
    bool clearError = false,
  }) =>
      NotificationHealthState(
        health: health ?? this.health,
        isLoading: isLoading ?? this.isLoading,
        isTestPending: isTestPending ?? this.isTestPending,
        error: clearError ? null : (error ?? this.error),
      );
}
