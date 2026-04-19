import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';

/// Publishes a local audio file into the system MediaStore as a notification
/// sound (`IS_NOTIFICATION=1`), returning a globally-readable `content://`
/// URI that can be assigned to a notification channel. Decouples the
/// settings feature from platform MediaStore APIs.
abstract interface class INotificationSoundPublisher {
  /// Inserts [absolutePath] into MediaStore under [displayName]. Returns
  /// the MediaStore content URI on success.
  Future<Either<Failure, String>> publish({
    required String absolutePath,
    required String displayName,
    required String mimeType,
  });

  /// Removes a previously-published sound. Safe to call if the entry is
  /// already gone — returns `Right(Unit)` in that case.
  Future<Either<Failure, Unit>> unpublish(String contentUri);
}
