import '../../prayer/domain/entities/daily_prayer_times.dart';
import '../../prayer/domain/i_prayer_times_repository.dart';
import '../../prayer/domain/prayer_time_calculator.dart' as calc;

/// Builds the long-horizon list of prayer-time days the native engine needs
/// to schedule notifications for. Keeps re-scheduling work in Dart (where
/// the prayer cache lives) and lets Kotlin stay storage-agnostic.
///
/// Default horizon is 7 days — enough that the device can sit unopened for
/// a week and still fire notifications, while staying well under the
/// 30-day cap the engine validates against.
class HorizonBuilder {
  final IPrayerTimesRepository _repo;
  final int horizonDays;

  HorizonBuilder(this._repo, {this.horizonDays = 7});

  /// Returns up to [horizonDays] consecutive [DailyPrayerTimes], starting
  /// from today. Days the cache cannot serve are skipped silently — the
  /// engine simply schedules fewer notifications rather than throwing.
  List<DailyPrayerTimes> build(DateTime now) {
    final out = <DailyPrayerTimes>[];
    final today = _repo.getToday();
    if (today != null) out.add(today);
    for (var d = 1; d < horizonDays; d++) {
      final date = DateTime(now.year, now.month, now.day + d);
      final entry = _repo.getTomorrowByKey(calc.dateKey(date));
      if (entry != null) out.add(entry);
    }
    return out;
  }
}
