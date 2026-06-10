import 'takbeerat_reciter.dart';

/// Immutable snapshot of the Eid Takbeerat Remote Config payload.
///
/// Every flag has a safe default so a failed RC fetch still produces a usable
/// (feature-off) value via [TakbeeratConfig.disabled].
class TakbeeratConfig {
  const TakbeeratConfig({
    required this.isFeatureEnabled,
    required this.hasForceHide,
    required this.hasForceShow,
    required this.fitrStartOffsetDays,
    required this.fitrEndOffsetDays,
    required this.adhaStartOffsetDays,
    required this.adhaEndOffsetDays,
    required this.reciters,
  });

  /// Master kill switch. `false` ⇒ feature stays dark regardless of any other
  /// flag in this config.
  final bool isFeatureEnabled;

  /// Emergency hide. Used to suppress the card mid-season without a release.
  final bool hasForceHide;

  /// Forces the card visible even when the Hijri calculation says we are not
  /// in an Eid window — used when local sighting differs from the algorithm.
  final bool hasForceShow;

  /// How many days before 1 Shawwal the card should appear (inclusive).
  final int fitrStartOffsetDays;

  /// How many days after 1 Shawwal the card should remain (inclusive).
  final int fitrEndOffsetDays;

  /// How many days before 10 Dhul-Hijjah the card should appear (inclusive).
  final int adhaStartOffsetDays;

  /// How many days after 10 Dhul-Hijjah the card should remain (inclusive).
  /// Default covers the four Tashreeq days.
  final int adhaEndOffsetDays;

  final List<TakbeeratReciter> reciters;

  /// Safe baseline used when Remote Config is unreachable or malformed.
  /// Keeps the feature invisible — never accidentally enabled.
  factory TakbeeratConfig.disabled() => const TakbeeratConfig(
    isFeatureEnabled: false,
    hasForceHide: false,
    hasForceShow: false,
    fitrStartOffsetDays: 1,
    fitrEndOffsetDays: 0,
    adhaStartOffsetDays: 2,
    adhaEndOffsetDays: 3,
    reciters: <TakbeeratReciter>[],
  );
}
