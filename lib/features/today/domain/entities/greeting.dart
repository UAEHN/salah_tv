/// Period of the day used to drive the greeting card copy.
enum GreetingPeriod { morning, evening }

/// Domain descriptor for the user-facing greeting. The presentation layer
/// resolves [titleKey] and [subtitleKey] against `AppLocalizations`.
class Greeting {
  final GreetingPeriod period;

  /// Localization key for the headline (e.g. `greetingMorningTitle`).
  final String titleKey;

  /// Localization key for the supporting line (e.g. `greetingMorningSubtitle`).
  final String subtitleKey;

  const Greeting({
    required this.period,
    required this.titleKey,
    required this.subtitleKey,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Greeting &&
          other.period == period &&
          other.titleKey == titleKey &&
          other.subtitleKey == subtitleKey;

  @override
  int get hashCode => Object.hash(period, titleKey, subtitleKey);
}
