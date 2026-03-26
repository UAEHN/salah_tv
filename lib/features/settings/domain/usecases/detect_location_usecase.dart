import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/detected_location.dart';
import '../i_location_detector.dart';

class DetectLocationUseCase {
  final ILocationDetector _detector;

  DetectLocationUseCase(this._detector);

  Future<Either<Failure, DetectedLocation>> call() =>
      _detector.detectLocation();
}
