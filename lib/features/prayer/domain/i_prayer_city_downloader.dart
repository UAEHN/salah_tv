import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'cancellation_token.dart';

abstract class IPrayerCityDownloader {
  /// Downloads prayer JSON for [country]/[citySlug] from CDN.
  /// Returns `Left(NetworkFailure)` on any network or parse error.
  /// Returns `Left(CancelledFailure)` if [cancelToken] is cancelled.
  Future<Either<Failure, ({String hash, List<List<int>> rows})>> fetchCity(
    String country,
    String citySlug,
    CancellationToken cancelToken,
  );

  /// Downloads manifest.json from CDN (8 s timeout).
  /// Returns null silently on any error — never throws.
  Future<Map<String, String>?> fetchManifest();
}
