import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/widget_payload.dart';

/// Publishes prayer snapshots to the Android home-screen widget process.
/// Implementations must be cheap to call — the bridge calls [publish]
/// once per minute (and on key prayer-state transitions).
abstract class IHomeWidgetRepository {
  Future<Either<Failure, Unit>> publish(WidgetPayload payload);
  Future<Either<Failure, Unit>> clear();
}
