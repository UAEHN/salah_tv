import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../domain/i_notification_sound_publisher.dart';

/// TV-only publisher that performs no MediaStore registration.
///
/// On TV the adhan/iqama plays through the in-app [AudioService] via a
/// [DeviceFileSource] resolved from the file name — it never goes through a
/// system notification channel, so there is nothing to publish. Registering
/// the real [AndroidMediaStorePublisher] here would be pointless and, on TV
/// boxes without a MediaStore provider, would fail and roll back the import.
///
/// Returns an empty content URI on [publish]; [CustomAdhan.contentUri] stays
/// empty and the delete path skips `unpublish` for empty URIs, so the file +
/// MediaStore sinks remain consistent from the caller's perspective.
class NoOpNotificationSoundPublisher implements INotificationSoundPublisher {
  const NoOpNotificationSoundPublisher();

  @override
  Future<Either<Failure, String>> publish({
    required String absolutePath,
    required String displayName,
    required String mimeType,
  }) async => const Right('');

  @override
  Future<Either<Failure, Unit>> unpublish(String contentUri) async =>
      const Right(unit);
}
