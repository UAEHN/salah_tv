/// One-shot flag: has the user been asked whether they want the full
/// Mushaf cached for offline use? The reader tab triggers an
/// interactive bottom sheet the FIRST time the user lands there; the
/// flag prevents the sheet from re-appearing on every tab visit
/// regardless of which option the user picked.
abstract class IQuranOfflineChoiceRepository {
  /// `true` once the user has answered the offline-mode prompt at
  /// least once. Defaults to `false` on read errors so the user
  /// still gets a chance to opt in.
  Future<bool> hasChosenOfflineMode();

  /// Persist that the user has answered the prompt. Idempotent —
  /// safe to call from either button's handler.
  Future<void> markChosen();
}
