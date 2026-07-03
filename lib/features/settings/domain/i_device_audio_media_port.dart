import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/audio_media.dart';

/// Play-compliant platform bridge for the TV custom-sound browser. Lists audio
/// through MediaStore (minimum-scope `READ_MEDIA_AUDIO`) instead of walking raw
/// paths, and copies a picked `content://` file into the app's cache so the
/// existing import use-case can take over.
///
/// TV-only: mobile imports custom adhans via the system SAF picker directly.
abstract interface class IDeviceAudioMediaPort {
  /// Whether the minimum-scope audio read permission is granted.
  Future<bool> hasPermission();

  /// Shows the standard runtime permission dialog and completes once the user
  /// has decided, so the caller can re-check [hasPermission] and load the list
  /// immediately — no manual retry needed.
  Future<void> requestPermission();

  /// Folders (buckets) that contain audio.
  Future<Either<Failure, List<AudioFolder>>> listFolders();

  /// Audio files inside [bucketId], filtered to importable extensions.
  Future<Either<Failure, List<AudioFile>>> listFiles(String bucketId);

  /// Copies [uri] into cache and returns the temp path to import from.
  Future<Either<Failure, String>> copyToTemp(String uri, String displayName);

  /// Whether a system document picker (SAF) exists for the fallback button.
  /// False on TV boxes without DocumentsUI (e.g. Mi TV).
  Future<bool> hasSystemPicker();
}
