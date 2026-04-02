import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../injection.dart';
import '../platform_config.dart';

Future<PlatformConfig> bootstrapPlatform() async {
  final platformConfig = PlatformConfig();
  await platformConfig.detect();
  getIt.registerSingleton<PlatformConfig>(platformConfig);

  await WakelockPlus.enable();
  await _configureSystemUi(platformConfig);
  return platformConfig;
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
