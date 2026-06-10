import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/push_permission_status.dart';
import '../i_push_notifications_repository.dart';

/// Boot-time orchestrator for the push pipeline:
///   1. Read current permission (do NOT prompt — the onboarding gate handles
///      prompting in a user-visible context).
///   2. If granted, fetch the FCM token so it is cached for later use.
///   3. Subscribe to the default broadcast topics every boot (idempotent).
///
/// Called from `app_startup` after Firebase is initialized. Failure of any
/// step is logged but does not block app boot — push is best-effort.
class InitializePushNotifications {
  final IPushNotificationsRepository repo;
  final List<String> defaultTopics;

  const InitializePushNotifications({
    required this.repo,
    this.defaultTopics = const ['all_users'],
  });

  Future<Either<Failure, String?>> call() async {
    final statusEither = await repo.getPermissionStatus();
    final status = statusEither.fold(
      (_) => PushPermissionStatus.notDetermined,
      (s) => s,
    );
    if (status != PushPermissionStatus.granted &&
        status != PushPermissionStatus.provisional) {
      return const Right<Failure, String?>(null);
    }
    for (final topic in defaultTopics) {
      await repo.subscribeToTopic(topic);
    }
    return repo.getToken();
  }
}
