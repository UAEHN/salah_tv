import 'package:flutter/services.dart';

/// Launches external URLs via the native Android Intent system.
/// No third-party packages required — uses the existing [ghasaq/platform] channel.
abstract class PlatformLauncher {
  static const _channel = MethodChannel('ghasaq/platform');

  static Future<void> openUrl(String url) async {
    await _channel.invokeMethod<bool>('openUrl', {'url': url});
  }
}
