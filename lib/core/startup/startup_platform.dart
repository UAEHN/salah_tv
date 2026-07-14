import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../injection.dart';
import '../error_reporting/context/device_context_channel.dart';
import '../platform_config.dart';

Future<PlatformConfig> bootstrapPlatform() async {
  final platformConfig = PlatformConfig();
  await platformConfig.detect();
  getIt.registerSingleton<PlatformConfig>(platformConfig);

  _capImageCache(
    isTV: platformConfig.isTV,
    ramTotalMb: platformConfig.isTV ? await _readRamTotalMb() : null,
  );

  // TV is always-on by design; mobile lets the OS manage screen timeout normally.
  if (platformConfig.isTV) await WakelockPlus.enable();
  await _configureSystemUi(platformConfig);
  return platformConfig;
}

/// Best-effort device RAM read (fail-soft: null on any channel failure, so the
/// cap falls back to the capable-box default rather than blocking startup).
Future<int?> _readRamTotalMb() async {
  try {
    final ctx = await DeviceContextChannel().read();
    final v = ctx['ram_total_mb'];
    return v is num ? v.toInt() : null;
  } catch (_) {
    return null;
  }
}

/// Pure decision for the decoded-image-cache budget. Exposed for unit testing
/// the low-RAM scaling below.
///
/// A flat 50 MB image cache on a <1 GB / 720p TV box (observed running with
/// <300 MB free) is a large slice of the little free memory and pressures the
/// OS into freezing the whole app — surfaced as `countdown_stall` (a 150s+ tick
/// freeze) on exactly those weak boxes. Scale the ceiling to the device: the
/// weakest boxes get a much smaller cache; capable TVs keep the §9 50 MB.
({int mb, int entries}) imageCacheBudget({required bool isTV, int? ramTotalMb}) {
  if (!isTV) return (mb: 30, entries: 100);
  if (ramTotalMb != null && ramTotalMb <= 1024) return (mb: 16, entries: 60);
  if (ramTotalMb != null && ramTotalMb <= 1536) return (mb: 28, entries: 120);
  return (mb: 50, entries: 200);
}

/// Caps Flutter's decoded-image cache (§9 CLAUDE.md). The framework default is
/// ~100 MB / 1000 entries, which an always-on TV box can let creep until a weak
/// GPU/heap is exhausted and the UI freezes while the engine keeps ticking.
void _capImageCache({required bool isTV, int? ramTotalMb}) {
  final budget = imageCacheBudget(isTV: isTV, ramTotalMb: ramTotalMb);
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSizeBytes = budget.mb << 20; // MB → bytes
  cache.maximumSize = budget.entries; // entry count
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
