import '../../domain/entities/eid_visibility.dart';
import '../../domain/entities/takbeerat_reciter.dart';

/// Snapshot of everything the home card needs to render — visibility plus
/// the candidate reciter list resolved from Remote Config. Held together
/// so the card never re-fetches or re-derives.
class TakbeeratVisibilityState {
  const TakbeeratVisibilityState({
    required this.visibility,
    required this.reciters,
  });

  factory TakbeeratVisibilityState.hidden() => TakbeeratVisibilityState(
    visibility: EidVisibility.hidden(),
    reciters: const [],
  );

  final EidVisibility visibility;
  final List<TakbeeratReciter> reciters;

  /// The reciter the card will play when the user taps the toggle. Currently
  /// the first entry — picker UI lands in a follow-up.
  TakbeeratReciter? get defaultReciter =>
      reciters.isEmpty ? null : reciters.first;
}
