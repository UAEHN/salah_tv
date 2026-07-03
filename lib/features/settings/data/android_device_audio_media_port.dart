import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/audio_media.dart';
import '../domain/i_device_audio_media_port.dart';

/// [IDeviceAudioMediaPort] backed by the native `ghasaq/platform` channel
/// (handlers in `MainActivity.kt`).
class AndroidDeviceAudioMediaPort implements IDeviceAudioMediaPort {
  static const _channel = MethodChannel('ghasaq/platform');

  const AndroidDeviceAudioMediaPort();

  @override
  Future<bool> hasPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasAudioPermission') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod<void>('requestAudioPermission');
    } on PlatformException {
      // Nothing to recover — Dart re-checks hasPermission on resume.
    } on MissingPluginException {
      // Older native build without the handler.
    }
  }

  @override
  Future<Either<Failure, List<AudioFolder>>> listFolders() async {
    try {
      final raw = await _channel.invokeListMethod<dynamic>('listAudioFolders');
      final folders = (raw ?? const [])
          .whereType<Map>()
          .map(
            (m) => AudioFolder(
              id: (m['id'] as String?) ?? '',
              name: (m['name'] as String?) ?? '',
            ),
          )
          .where((f) => f.id.isNotEmpty)
          .toList(growable: false);
      return Right(folders);
    } on PlatformException catch (e) {
      return Left(CacheFailure('listAudioFolders failed: ${e.message}'));
    } on MissingPluginException {
      return const Left(CacheFailure('audio listing unavailable'));
    }
  }

  @override
  Future<Either<Failure, List<AudioFile>>> listFiles(String bucketId) async {
    try {
      final raw = await _channel.invokeListMethod<dynamic>(
        'listAudioInFolder',
        {'bucketId': bucketId},
      );
      final files = (raw ?? const [])
          .whereType<Map>()
          .map(
            (m) => AudioFile(
              uri: (m['uri'] as String?) ?? '',
              name: (m['name'] as String?) ?? '',
            ),
          )
          .where((f) => f.uri.isNotEmpty)
          .toList(growable: false);
      return Right(files);
    } on PlatformException catch (e) {
      return Left(CacheFailure('listAudioInFolder failed: ${e.message}'));
    } on MissingPluginException {
      return const Left(CacheFailure('audio listing unavailable'));
    }
  }

  @override
  Future<Either<Failure, String>> copyToTemp(
    String uri,
    String displayName,
  ) async {
    try {
      final path = await _channel.invokeMethod<String>('copyUriToTemp', {
        'uri': uri,
        'displayName': displayName,
      });
      if (path == null || path.isEmpty) {
        return const Left(CacheFailure('copy returned empty path'));
      }
      return Right(path);
    } on PlatformException catch (e) {
      return Left(CacheFailure('copyUriToTemp failed: ${e.message}'));
    } on MissingPluginException {
      return const Left(CacheFailure('copy unavailable'));
    }
  }

  @override
  Future<bool> hasSystemPicker() async {
    try {
      return await _channel.invokeMethod<bool>('hasSystemFilePicker') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
