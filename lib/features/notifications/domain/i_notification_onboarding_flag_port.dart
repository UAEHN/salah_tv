/// Read/write port for the "user has finished notification onboarding"
/// flag. Lets the notifications feature depend on settings without
/// importing `settings/presentation/` directly — the implementation
/// lives in the settings feature and is registered in DI.
abstract class INotificationOnboardingFlagPort {
  /// True once the user has been walked through the permission flow.
  bool get isOnboardingDone;

  /// Listens for changes so the gate can switch its rendered child without
  /// the consumer needing to reach into the settings layer.
  void addListener(void Function() listener);
  void removeListener(void Function() listener);

  /// Persists "done" — called when the flow reaches its final step or the
  /// user dismisses it explicitly.
  Future<void> markDone();
}
