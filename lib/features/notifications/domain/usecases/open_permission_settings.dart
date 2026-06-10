import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../i_notification_health_port.dart';

/// One use-case per permission-page launcher. Keeps the cubit free of
/// `INotificationHealthPort` plumbing so it depends only on use-cases —
/// matching the pattern other features (`prayer/domain/usecases`,
/// `settings/domain/usecases`) follow.
abstract class _PermissionUseCase {
  final INotificationHealthPort port;
  const _PermissionUseCase(this.port);

  Future<Either<Failure, Success>> _run(Future<void> Function() op) async {
    try {
      await op();
      return const Right(Success());
    } on Exception catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }
}

class RequestPostNotifications extends _PermissionUseCase {
  const RequestPostNotifications(super.port);
  Future<Either<Failure, Success>> call() =>
      _run(port.requestPostNotifications);
}

class OpenExactAlarmSettings extends _PermissionUseCase {
  const OpenExactAlarmSettings(super.port);
  Future<Either<Failure, Success>> call() => _run(port.openExactAlarmSettings);
}

class OpenBatteryOptimizationSettings extends _PermissionUseCase {
  const OpenBatteryOptimizationSettings(super.port);
  Future<Either<Failure, Success>> call() =>
      _run(port.openBatteryOptimizationSettings);
}

class OpenNotificationSettings extends _PermissionUseCase {
  const OpenNotificationSettings(super.port);
  Future<Either<Failure, Success>> call() =>
      _run(port.openNotificationSettings);
}

class OpenOemAutostart extends _PermissionUseCase {
  const OpenOemAutostart(super.port);
  Future<Either<Failure, Success>> call() => _run(port.openOemAutostart);
}
