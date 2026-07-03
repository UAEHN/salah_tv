/// Persists which morning/evening session-adhkar categories have already been
/// shown today, so the app-open catch-up ([RecoveryMixin.recoverSessionAdhkar])
/// survives a full app kill+restart and never re-shows a session the user
/// already saw earlier the same day. Day-scoped: a record from an earlier day
/// reads back as empty.
abstract class ISessionAdhkarLogPort {
  /// Categories ('morning'/'evening') recorded as shown on [dayKey].
  /// Empty when nothing was recorded for that day yet.
  Future<Set<String>> shownOn(String dayKey);

  /// Records [category] as shown on [dayKey], replacing any record from a
  /// different (stale) day so only today's categories are ever returned.
  Future<void> markShown(String dayKey, String category);
}
