import '../../../prayer/domain/entities/daily_prayer_times.dart';
import '../../../prayer/domain/i_prayer_times_repository.dart';

/// Loads N days of prayer times starting from [from], so the widget keeps
/// rendering correctly without the app being opened. 30 days is enough for
/// a month of background ticks; the native side will pick the first slot
/// whose timestamp is in the future.
class GetUpcomingScheduleUseCase {
  final IPrayerTimesRepository _repo;
  const GetUpcomingScheduleUseCase(this._repo);

  Future<List<DailyPrayerTimes>> call({
    required DateTime from,
    int days = 30,
  }) async {
    final start = DateTime(from.year, from.month, from.day);
    final result = <DailyPrayerTimes>[];
    for (var i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      final either = await _repo.getByDate(date);
      either.fold((_) => null, (data) {
        if (data != null) result.add(data);
      });
    }
    return result;
  }
}
