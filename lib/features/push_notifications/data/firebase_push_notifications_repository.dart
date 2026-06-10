import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../core/error/failures.dart';
import '../../../core/error/push_notification_failure.dart';
import '../domain/entities/push_permission_status.dart';
import '../domain/i_push_notifications_repository.dart';

/// FCM-backed implementation. Wrapped in try/catch at every boundary so
/// transient native errors (Play Services missing, network blip) surface
/// as [PushNotificationFailure] instead of crashing the UI.
class FirebasePushNotificationsRepository
    implements IPushNotificationsRepository {
  final FirebaseMessaging _messaging;

  FirebasePushNotificationsRepository({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  @override
  Future<Either<Failure, PushPermissionStatus>> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return Right(_mapStatus(settings.authorizationStatus));
    } catch (e) {
      return Left(PushNotificationFailure('requestPermission failed: $e'));
    }
  }

  @override
  Future<Either<Failure, PushPermissionStatus>> getPermissionStatus() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return Right(_mapStatus(settings.authorizationStatus));
    } catch (e) {
      return Left(PushNotificationFailure('getPermissionStatus failed: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode && token != null) {
        debugPrint('[FCM] token: $token');
      }
      return Right(token);
    } catch (e) {
      return Left(PushNotificationFailure('getToken failed: $e'));
    }
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<Either<Failure, Unit>> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) debugPrint('[FCM] subscribed: $topic');
      return const Right(unit);
    } catch (e) {
      return Left(PushNotificationFailure('subscribe($topic) failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      return const Right(unit);
    } catch (e) {
      return Left(PushNotificationFailure('unsubscribe($topic) failed: $e'));
    }
  }

  PushPermissionStatus _mapStatus(AuthorizationStatus s) {
    switch (s) {
      case AuthorizationStatus.authorized:
        return PushPermissionStatus.granted;
      case AuthorizationStatus.denied:
        return PushPermissionStatus.denied;
      case AuthorizationStatus.provisional:
        return PushPermissionStatus.provisional;
      case AuthorizationStatus.notDetermined:
        return PushPermissionStatus.notDetermined;
    }
  }
}
