abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure() : super('Location permission denied');
}

class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure() : super('Location service is disabled');
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

/// Typed exceptions thrown by datasources and caught by repositories.
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
}
