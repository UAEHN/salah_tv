import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../core/error/failures.dart';
import '../domain/i_notification_sound_publisher.dart';

class AndroidMediaStorePublisher implements INotificationSoundPublisher {
  static const _channel = MethodChannel('ghasaq/platform');

  @override
  Future<Either<Failure, String>> publish({
    required String absolutePath,
    required String displayName,
    required String mimeType,
  }) async {
    try {
      final uri = await _channel.invokeMethod<String>('publishAdhanSound', {
        'path': absolutePath,
        'displayName': displayName,
        'mimeType': mimeType,
      });
      if (uri == null || uri.isEmpty) {
        return const Left(CacheFailure('platform returned empty URI'));
      }
      return Right(uri);
    } on PlatformException catch (e) {
      return Left(CacheFailure('publish failed: ${e.message ?? e.code}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> unpublish(String contentUri) async {
    try {
      await _channel.invokeMethod<bool>('unpublishAdhanSound', {
        'uri': contentUri,
      });
      return const Right(unit);
    } on PlatformException catch (e) {
      return Left(CacheFailure('unpublish failed: ${e.message ?? e.code}'));
    }
  }
}
