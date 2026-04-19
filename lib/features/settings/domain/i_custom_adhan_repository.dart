import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/custom_adhan.dart';

/// Manages the lifecycle of user-imported adhan audio files inside the
/// app's documents directory. Metadata (id/label) is persisted by the
/// settings layer; this repository owns only the file bytes.
abstract interface class ICustomAdhanRepository {
  /// Copies [srcPath] into the app dir and returns a [CustomAdhan] carrying
  /// the generated id, the user-provided [label], and the resolved file name.
  Future<Either<Failure, CustomAdhan>> importFromPath(
    String srcPath,
    String label,
  );

  /// Deletes the app-dir copy for [fileName] AND unpublishes [contentUri]
  /// from MediaStore. Missing files/entries are treated as success so the
  /// op is idempotent.
  Future<Either<Failure, Unit>> deleteFile({
    required String fileName,
    required String contentUri,
  });

  /// Resolves a stored [fileName] to an absolute path playable by
  /// `DeviceFileSource`.
  Future<Either<Failure, String>> absolutePathOf(String fileName);
}
