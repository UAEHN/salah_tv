import 'package:hijri/hijri_calendar.dart';

import '../domain/entities/hijri_snapshot.dart';
import '../domain/i_hijri_date_provider.dart';

/// Concrete [IHijriDateProvider] backed by `package:hijri`.
/// Kept tiny on purpose: the only role of this layer is to keep the
/// third-party `HijriCalendar` type out of the domain.
class HijriDateProvider implements IHijriDateProvider {
  const HijriDateProvider();

  @override
  HijriSnapshot fromGregorian(DateTime gregorian) {
    final h = HijriCalendar.fromDate(gregorian);
    return HijriSnapshot(
      year: h.hYear,
      month: h.hMonth,
      day: h.hDay,
      lengthOfMonth: h.lengthOfMonth,
    );
  }
}
