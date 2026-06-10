import 'package:adhan_dart/adhan_dart.dart';

/// String keys persisted in [AppSettings.highLatitudeRule] for the
/// four supported high-latitude adjustments.
///
/// Why expose this to users: above ~48°N the standard 12–18° twilight angle
/// for Fajr/Isha breaks down in summer (the sun never dips deep enough below
/// the horizon). Different mosques across Europe pick different conventions
/// to cope — exposing the choice lets the user match their local mosque
/// instead of being forced into the single hard-coded fallback.
class HighLatitudeRuleKey {
  HighLatitudeRuleKey._();

  /// Legacy behavior: apply [HighLatitudeRule.middleOfTheNight] only when
  /// latitude exceeds the in-source threshold. Default for existing users
  /// so we don't surprise anyone who never visits the new setting.
  static const auto = 'auto';

  /// Fajr/Isha placed at the midpoint between sunset and sunrise of the
  /// night. The most conservative and widely-published European fallback.
  static const middleOfTheNight = 'middle_of_the_night';

  /// Fajr starts at the first seventh of the night, Isha at the last
  /// seventh. Often used by South-Asian-rooted mosques in the UK.
  static const seventhOfTheNight = 'seventh_of_the_night';

  /// Twilight angles are linearly reduced as days lengthen — a smooth
  /// compromise between true astronomical times and a fixed split.
  static const twilightAngle = 'twilight_angle';

  /// Ordered list of user-selectable values for the picker UI.
  static const all = <String>[
    auto,
    middleOfTheNight,
    seventhOfTheNight,
    twilightAngle,
  ];
}

/// Maps a [HighLatitudeRuleKey] to the adhan_dart enum, or `null` for
/// [HighLatitudeRuleKey.auto] (meaning: let the calculator decide based
/// on latitude).
HighLatitudeRule? highLatitudeRuleFor(String key) {
  return switch (key) {
    HighLatitudeRuleKey.middleOfTheNight => HighLatitudeRule.middleOfTheNight,
    HighLatitudeRuleKey.seventhOfTheNight => HighLatitudeRule.seventhOfTheNight,
    HighLatitudeRuleKey.twilightAngle => HighLatitudeRule.twilightAngle,
    _ => null,
  };
}
