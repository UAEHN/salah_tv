import 'entities/adhkar_session.dart';
import 'i_adhkar_state_repository.dart';

/// Pure domain check: should the adhkar hero be displayed right now?
///
/// Encapsulates the time-window and session-shown-today policies so that
/// presentation widgets stay display-only.
bool isAdhkarEligible({
  required AdhkarSession session,
  required IAdhkarStateRepository repo,
  required bool isAdhkarEnabled,
  required bool isCycleActive,
  required String nextPrayerKey,
  required int countdownSeconds,
}) {
  if (!isAdhkarEnabled || isCycleActive || session == AdhkarSession.none) {
    return false;
  }

  // Show if: not shown today OR session is currently active (don't interrupt).
  final canShow = session == AdhkarSession.morning
      ? (!repo.hasMorningAdhkarShownToday() || repo.isMorningSessionActive)
      : (!repo.hasEveningAdhkarShownToday() || repo.isEveningSessionActive);
  if (!canShow) return false;

  // Morning: hide from 10:00 AM onward.
  // Evening: only valid while waiting for Maghrib, hide 5 min before.
  if (session == AdhkarSession.morning) {
    return DateTime.now().hour < 10;
  }
  return nextPrayerKey == 'maghrib' && countdownSeconds > 5 * 60;
}
