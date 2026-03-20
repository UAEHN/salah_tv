import 'entities/adhkar_session.dart';
import 'entities/dhikr.dart';

/// Tracks the once-per-day morning adhkar session state
/// and exposes adhkar content retrieval.
abstract class IAdhkarStateRepository {
  /// Returns the adhkar list for the given [session].
  List<Dhikr> forSession(AdhkarSession session);

  /// True while [AdhkarHeroContent] is mounted for the morning session.
  bool get isMorningSessionActive;

  /// True if morning adhkar have already been shown today (persisted).
  bool hasMorningAdhkarShownToday();

  /// Persists today's date and activates the morning runtime flag.
  Future<void> startMorningSession();

  /// Clears the morning runtime flag (called on widget dispose or completion).
  void endMorningSession();

  /// True while [AdhkarHeroContent] is mounted for the evening session.
  bool get isEveningSessionActive;

  /// True if evening adhkar have already been shown today (persisted).
  bool hasEveningAdhkarShownToday();

  /// Persists today's date and activates the evening runtime flag.
  Future<void> startEveningSession();

  /// Clears the evening runtime flag (called on widget dispose or completion).
  void endEveningSession();
}
