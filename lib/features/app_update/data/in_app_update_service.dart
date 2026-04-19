import 'package:in_app_update/in_app_update.dart';

/// Wraps the Google Play In-App Updates API.
/// Shows the native Play Store update UI when a new version is available.
/// Fails silently — app is usable even if update check fails (e.g. not on Play).
class InAppUpdateService {
  Future<void> checkAndPrompt() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (_) {}
  }
}
