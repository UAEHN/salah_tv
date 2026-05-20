import 'entities/hijri_snapshot.dart';

/// Converts a Gregorian instant into a [HijriSnapshot].
/// Pure abstraction so the use-case layer never imports the `hijri` package
/// directly — keeping domain free of external dependencies.
abstract class IHijriDateProvider {
  HijriSnapshot fromGregorian(DateTime gregorian);
}
