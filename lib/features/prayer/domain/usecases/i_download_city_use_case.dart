import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../cancellation_token.dart';

abstract class IDownloadCityUseCase {
  Future<Either<Failure, Success>> call({
    required String countryKey,
    required String cityName,
    required CancellationToken cancelToken,
  });
}
