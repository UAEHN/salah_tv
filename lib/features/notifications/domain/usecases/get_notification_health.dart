import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_health.dart';
import '../i_notification_health_port.dart';

/// Reads the current notification health snapshot. Wraps the port call so
/// presentation never touches the platform channel layer directly.
class GetNotificationHealth {
  final INotificationHealthPort _port;
  const GetNotificationHealth(this._port);

  Future<Either<Failure, NotificationHealth>> call() async {
    try {
      final h = await _port.read();
      return Right(h);
    } on Exception catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }
}
