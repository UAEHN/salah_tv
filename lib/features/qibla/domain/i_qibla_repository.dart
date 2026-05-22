import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'entities/qibla_data.dart';

/// Port: streams live Qibla data (bearing + compass heading + distance).
/// Emits [Left<Failure>] on permission/location errors, then stops.
/// Emits [Right<QiblaData>] continuously while sensors are active.
abstract class IQiblaRepository {
  Stream<Either<Failure, QiblaData>> watchQibla();

  /// Detaches from accelerometer + magnetometer streams so the OS can put
  /// the sensors back to sleep. Cached bearing / distance survive so a
  /// later [resumeSensors] is instant. Safe to call when not started.
  void pauseSensors();

  /// Re-attaches sensor listeners after a prior [pauseSensors]. Safe to
  /// call when already running. If the repo was never started, this is a
  /// no-op — the next [watchQibla] call will boot the pipeline.
  void resumeSensors();

  Future<void> dispose();
}
