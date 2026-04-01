import '../entities/detected_location.dart';
import '../i_location_detector.dart';
import '../i_settings_repository.dart';

/// Checks if this is the first launch and auto-detects location if so.
///
/// Returns the detected location or null if not first launch / detection failed.
/// Shared by [HomeScreen] (TV) and [MobileShell] (mobile) to avoid duplication.
class FirstLaunchLocationUseCase {
  final ISettingsRepository _repo;
  final ILocationDetector _detector;

  FirstLaunchLocationUseCase(this._repo, this._detector);

  Future<DetectedLocation?> call() async {
    final isFirst = await _repo.isFirstLaunch();
    if (!isFirst) return null;

    final result = await _detector.detectLocation();
    return result.fold((_) => null, (loc) {
      // Mark launched only after successful detection so a transient GPS
      // failure doesn't permanently disable auto-detect on next launch.
      _repo.markLaunched();
      return loc;
    });
  }
}
