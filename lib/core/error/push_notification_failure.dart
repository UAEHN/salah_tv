import 'failures.dart';

class PushNotificationFailure extends Failure {
  const PushNotificationFailure(super.message);
}

class PushNotificationException implements Exception {
  final String message;
  const PushNotificationException(this.message);
}
