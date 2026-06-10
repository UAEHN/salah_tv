import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../injection.dart';
import '../platform_config.dart';

Future<PlatformConfig> bootstrapPlatform() async {
  final platformConfig = PlatformConfig();
  await platformConfig.detect();
  getIt.registerSingleton<PlatformConfig>(platformConfig);

  _capImageCache(isTV: platformConfig.isTV);

  // TV is always-on by design; mobile lets the OS manage screen timeout normally.
  if (platformConfig.isTV) await WakelockPlus.enable();
  await _configureSystemUi(platformConfig);
  return platformConfig;
}

/// Caps Flutter's decoded-image cache (§9 CLAUDE.md). The framework default is
/// ~100 MB / 1000 entries, which an always-on TV box can let creep until a weak
/// GPU/heap is exhausted and the UI freezes while the engine keeps ticking.
/// TV runs 24/7 so it gets the §9 50 MB ceiling; mobile a tighter 30 MB.
void _capImageCache({required bool isTV}) {
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSizeBytes = (isTV ? 50 : 30) << 20; // MB → bytes
  cache.maximumSize = isTV ? 200 : 100; // entry count
}

Future<void> _configureSystemUi(PlatformConfig platformConfig) async {
  if (platformConfig.isTV) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return;
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
