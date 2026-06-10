import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/push_permission_status.dart';

/// Public contract for the push notifications feature.
///
/// Implementations: [FirebasePushNotificationsRepository] on mobile,
/// [NoOpPushNotificationsRepository] on TV. Cross-feature consumers
/// never depend on FCM types directly — only this interface.
abstract class IPushNotificationsRepository {
  /// Requests the OS push-notification permission (Android 13+ runtime grant).
  /// On older Android versions this returns [PushPermissionStatus.granted].
  Future<Either<Failure, PushPermissionStatus>> requestPermission();

  /// Current permission status without prompting the user.
  Future<Either<Failure, PushPermissionStatus>> getPermissionStatus();

  /// Returns the device FCM token, or `null` if registration is not yet ready
  /// (e.g. Play Services unavailable). Idempotent.
  Future<Either<Failure, String?>> getToken();

  /// Emits whenever FCM rotates the token (uninstall/reinstall, data clear,
  /// security event). Subscribers must persist the new token server-side.
  Stream<String> get onTokenRefresh;

  /// Subscribes the device to a broadcast [topic].
  /// Topic names must match `[a-zA-Z0-9-_.~%]+` — caller is responsible for
  /// validation. Idempotent: safe to call on every boot.
  Future<Either<Failure, Unit>> subscribeToTopic(String topic);

  /// Removes the device from a previously-subscribed [topic].
  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic);
}
