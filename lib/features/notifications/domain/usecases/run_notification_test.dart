import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../i_notification_health_port.dart';

/// Schedules a one-shot test notification 15 seconds in the future via the
/// native engine. UI uses this from the health screen and the onboarding
/// flow's verification step.
class RunNotificationTest {
  final INotificationHealthPort _port;
  const RunNotificationTest(this._port);

  Future<Either<Failure, Success>> call() async {
    try {
      await _port.runTest();
      return const Right(Success());
    } on Exception catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }
}
