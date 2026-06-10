import 'eid_type.dart';

/// Result of [ShouldShowTakbeeratCard]. The presentation layer reads
/// [hasCard] to decide whether to render the home card at all, and
/// [activeEid] to pick the right greeting copy.
class EidVisibility {
  const EidVisibility({
    required this.hasCard,
    this.activeEid,
    this.isForcedByRemote = false,
  });

  /// True when the card should be rendered on the home screen.
  final bool hasCard;

  /// Which Eid is active — null when [hasCard] is false, and also null when
  /// the card is shown via [isForcedByRemote] outside any natural window.
  final EidType? activeEid;

  /// True when the card is visible only because of `takbeerat_force_show`.
  /// Useful for analytics and for branching the greeting copy if needed.
  final bool isForcedByRemote;

  factory EidVisibility.hidden() => const EidVisibility(hasCard: false);

  factory EidVisibility.showing({
    required EidType? eid,
    bool isForcedByRemote = false,
  }) => EidVisibility(
    hasCard: true,
    activeEid: eid,
    isForcedByRemote: isForcedByRemote,
  );
}
