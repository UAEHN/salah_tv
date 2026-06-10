import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/push_permission_status.dart';
import '../i_push_notifications_repository.dart';

/// Prompts the user for the push notification permission and, on grant,
/// subscribes the device to the default broadcast topics. UI invokes this
/// from a user-gesture context (settings toggle or onboarding card).
class RequestPushPermission {
  final IPushNotificationsRepository repo;
  final List<String> defaultTopics;

  const RequestPushPermission({
    required this.repo,
    this.defaultTopics = const ['all_users'],
  });

  Future<Either<Failure, PushPermissionStatus>> call() async {
    final result = await repo.requestPermission();
    return result.fold(Left.new, (status) async {
      if (status == PushPermissionStatus.granted ||
          status == PushPermissionStatus.provisional) {
        for (final topic in defaultTopics) {
          await repo.subscribeToTopic(topic);
        }
      }
      return Right(status);
    });
  }
}
