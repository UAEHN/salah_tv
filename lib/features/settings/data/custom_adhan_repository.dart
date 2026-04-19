import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as p;

import '../../../core/error/failures.dart';
import '../domain/entities/custom_adhan.dart';
import '../domain/i_custom_adhan_repository.dart';
import '../domain/i_notification_sound_publisher.dart';
import 'datasources/custom_adhan_file_datasource.dart';

class CustomAdhanRepository implements ICustomAdhanRepository {
  final CustomAdhanFileDataSource _files;
  final INotificationSoundPublisher _publisher;

  const CustomAdhanRepository(this._files, this._publisher);

  @override
  Future<Either<Failure, CustomAdhan>> importFromPath(
    String srcPath,
    String label,
  ) async {
    try {
      final id = _generateId();
      final fileName = await _files.copyToAppDir(srcPath, id);
      final absPath = await _files.resolvePath(fileName);
      final mime = _mimeFor(fileName);
      final uriResult = await _publisher.publish(
        absolutePath: absPath,
        displayName: fileName,
        mimeType: mime,
      );
      return uriResult.fold(
        (failure) async {
          // Roll back the copied file so we don't leak storage on a
          // publish failure — keeps the two sinks (file + MediaStore) in
          // sync from the caller's perspective.
          await _files.deleteFromAppDir(fileName);
          return Left<Failure, CustomAdhan>(failure);
        },
        (uri) => Right<Failure, CustomAdhan>(
          CustomAdhan(
            id: id,
            label: label.trim(),
            fileName: fileName,
            contentUri: uri,
          ),
        ),
      );
    } on StorageException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error importing adhan: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteFile({
    required String fileName,
    required String contentUri,
  }) async {
    try {
      if (contentUri.isNotEmpty) {
        await _publisher.unpublish(contentUri);
      }
      await _files.deleteFromAppDir(fileName);
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error deleting adhan: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> absolutePathOf(String fileName) async {
    try {
      final path = await _files.resolvePath(fileName);
      return Right(path);
    } on StorageException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error resolving path: $e'));
    }
  }

  String _generateId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  String _mimeFor(String fileName) {
    switch (p.extension(fileName).toLowerCase()) {
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.ogg':
        return 'audio/ogg';
      case '.m4a':
        return 'audio/mp4';
      default:
        return 'audio/*';
    }
  }
}
