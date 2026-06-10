import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';

/// Returns a stable, opaque per-install identifier. Generated once on first
/// boot and persisted locally — survives token rotations, settings clears
/// of the FCM token, and language changes. Reset only on app uninstall.
abstract class IInstallIdProvider {
  Future<Either<Failure, String>> getOrCreate();
}
