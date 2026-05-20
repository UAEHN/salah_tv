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

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CancelledFailure extends Failure {
  const CancelledFailure() : super('Cancelled');
}

/// Surfaced when the native notification engine refuses or fails a request
/// (channel missing on TV, platform exception during sync, etc.).
class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

/// Datasource-level exception thrown by the native notification channel
/// adapter; converted to [NotificationFailure] at the repository boundary.
class NotificationException implements Exception {
  final String message;
  const NotificationException(this.message);
}
