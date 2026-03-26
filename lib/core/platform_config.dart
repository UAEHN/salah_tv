import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

/// Convenience getter — zero changes required to existing call sites.
bool get kIsTV => GetIt.instance<PlatformConfig>().isTV;

/// Detects at runtime whether the app is running on an Android TV device.
/// Registered as a singleton in [GetIt] by [initDependencies] before the
/// widget tree is built.
class PlatformConfig {
  static const _channel = MethodChannel('ghasaq/platform');

  bool _isTV = false;

  /// `true` when [detect] confirmed an Android TV / Leanback UI mode.
  bool get isTV => _isTV;

  /// Queries the native [UiModeManager] once at startup.
  Future<void> detect() async {
    try {
      _isTV = await _channel.invokeMethod<bool>('isTV') ?? false;
    } on MissingPluginException {
      _isTV = false;
    } on PlatformException {
      _isTV = false;
    }
  }
}
