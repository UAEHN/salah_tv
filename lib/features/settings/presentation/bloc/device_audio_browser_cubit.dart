import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/audio_media.dart';
import '../../domain/i_device_audio_media_port.dart';
import 'device_audio_browser_state.dart';

/// Drives the TV audio browser over MediaStore (Play-compliant): permission
/// gating, folder listing, and per-folder file listing. Picking a file copies
/// it to a temp path the import use-case can consume.
class DeviceAudioBrowserCubit extends Cubit<DeviceAudioBrowserState> {
  final IDeviceAudioMediaPort _media;

  DeviceAudioBrowserCubit(this._media)
    : super(const DeviceAudioBrowserLoading());

  /// Entry point; also the "I granted access" retry.
  Future<void> start() async {
    emit(const DeviceAudioBrowserLoading());
    if (!await _media.hasPermission()) {
      if (isClosed) return;
      emit(const DeviceAudioBrowserNeedsPermission());
      return;
    }
    await _loadFolders();
  }

  /// Grants flow: the native call now resolves only after the user decides, so
  /// we can re-check and load the list immediately — no manual retry tap.
  Future<void> requestAccess() async {
    await _media.requestPermission();
    await start();
  }

  Future<void> _loadFolders() async {
    final result = await _media.listFolders();
    if (isClosed) return;
    result.fold((f) => emit(DeviceAudioBrowserError(f.message)), (folders) {
      emit(
        DeviceAudioBrowserReady(
          title: '',
          canGoUp: false,
          entries: folders
              .map((f) => BrowserEntry.folder(name: f.name, bucketId: f.id))
              .toList(growable: false),
        ),
      );
    });
  }

  Future<void> openFolder(String bucketId, String name) async {
    emit(const DeviceAudioBrowserLoading());
    final result = await _media.listFiles(bucketId);
    if (isClosed) return;
    result.fold((f) => emit(DeviceAudioBrowserError(f.message)), (files) {
      emit(
        DeviceAudioBrowserReady(
          title: name,
          canGoUp: true,
          entries: files
              .map((f) => BrowserEntry.file(name: f.name, uri: f.uri))
              .toList(growable: false),
        ),
      );
    });
  }

  Future<void> goUp() => _loadFolders();

  /// Copies a picked [file] into cache and returns the temp path to import
  /// from, or null on failure.
  Future<String?> resolveToTempPath(AudioFile file) async {
    final result = await _media.copyToTemp(file.uri, file.name);
    return result.fold((_) => null, (path) => path);
  }
}
