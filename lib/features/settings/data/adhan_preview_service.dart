import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../../core/adhan_sounds.dart';
import '../domain/entities/custom_adhan.dart';
import '../domain/i_adhan_preview_port.dart';
import '../domain/i_custom_adhan_repository.dart';

class AdhanPreviewService implements IAdhanPreviewPort {
  final AudioPlayer _player = AudioPlayer();
  final ICustomAdhanRepository? _customAdhans;

  AdhanPreviewService({ICustomAdhanRepository? customAdhans})
    : _customAdhans = customAdhans;

  @override
  Future<void> preview(String soundKey) async {
    try {
      await _player.stop();
      final source = await _resolveSource(soundKey);
      await _player.play(source);
    } catch (e) {
      debugPrint('[AdhanPreview] preview failed: $e');
    }
  }

  Future<Source> _resolveSource(String soundKey) async {
    final fileName = CustomAdhan.extractFileName(soundKey);
    final repo = _customAdhans;
    if (fileName != null && repo != null) {
      final result = await repo.absolutePathOf(fileName);
      final path = result.fold((_) => null, (p) => p);
      if (path != null) return DeviceFileSource(path);
    }
    final asset = kAdhanSounds
        .firstWhere((s) => s.key == soundKey, orElse: () => kAdhanSounds.first)
        .asset;
    return AssetSource(asset);
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('[AdhanPreview] stop failed: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
  }
}
