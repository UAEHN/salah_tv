import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'entities/qibla_data.dart';

/// Port: streams live Qibla data (bearing + compass heading + distance).
/// Emits [Left<Failure>] on permission/location errors, then stops.
/// Emits [Right<QiblaData>] continuously while sensors are active.
abstract class IQiblaRepository {
  Stream<Either<Failure, QiblaData>> watchQibla();
  Future<void> dispose();
}
