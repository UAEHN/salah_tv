import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/push_permission_status.dart';
import '../domain/i_push_notifications_repository.dart';

/// TV-side stub. Android TV does not use FCM — the always-on prayer cycle
/// engine handles adhan playback directly, so push delivery is irrelevant.
/// This implementation reports "granted" so feature gates that ask
/// `if (granted) showSomething` remain coherent without TV-specific code.
class NoOpPushNotificationsRepository implements IPushNotificationsRepository {
  const NoOpPushNotificationsRepository();

  @override
  Future<Either<Failure, PushPermissionStatus>> requestPermission() async =>
      const Right(PushPermissionStatus.granted);

  @override
  Future<Either<Failure, PushPermissionStatus>> getPermissionStatus() async =>
      const Right(PushPermissionStatus.granted);

  @override
  Future<Either<Failure, String?>> getToken() async =>
      const Right<Failure, String?>(null);

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<Either<Failure, Unit>> subscribeToTopic(String topic) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic) async =>
      const Right(unit);
}
