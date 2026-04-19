/// Contract for app-rating prompt state persistence.
/// Presentation layer depends only on this interface — never on the data impl.
abstract interface class IRatingService {
  /// Stores the first-launch timestamp if not already saved.
  Future<void> recordFirstLaunchIfNeeded();

  /// Returns true when all conditions are met to show the rating dialog:
  /// 7+ days since first launch, not yet rated, snooze period expired.
  Future<bool> shouldShowDialog();

  /// Permanently suppresses future prompts (user tapped "Rate").
  Future<void> markAsRated();

  /// Defers the next prompt by 14 days (user tapped "Later").
  Future<void> snooze();

  /// Defers the next prompt by 30 days (user tapped "Suggest").
  Future<void> snoozeLong();
}
