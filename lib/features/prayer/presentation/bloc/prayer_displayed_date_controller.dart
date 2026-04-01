import 'package:flutter/foundation.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/i_prayer_times_repository.dart';
import '../../domain/prayer_cycle_engine.dart';
import '../../domain/usecases/get_prayer_times_by_date_usecase.dart';
import 'prayer_state.dart';

class PrayerDisplayedDateController {
  final GetPrayerTimesByDateUseCase _getPrayerTimesByDate;
  DateTime? _selectedDate;
  DailyPrayerTimes? _selectedDatePrayers;
  bool _isBusy = false;

  PrayerDisplayedDateController(this._getPrayerTimesByDate);

  PrayerDisplayedDateController.fromRepository(IPrayerTimesRepository repo)
    : _getPrayerTimesByDate = GetPrayerTimesByDateUseCase(repo);

  bool get isBusy => _isBusy;

  bool shouldRefreshSelectedDate(AppSettings prev, AppSettings next) {
    return _selectedDate != null &&
        (next.selectedCity != prev.selectedCity ||
            next.selectedCountry != prev.selectedCountry ||
            next.isCalculatedLocation != prev.isCalculatedLocation ||
            next.selectedLatitude != prev.selectedLatitude ||
            next.selectedLongitude != prev.selectedLongitude ||
            next.calculationMethod != prev.calculationMethod);
  }

  void clear() {
    _selectedDate = null;
    _selectedDatePrayers = null;
  }

  void resetIfViewingToday(DateTime now) {
    if (_selectedDate != null && _sameDate(_selectedDate!, now)) clear();
  }

  PrayerState buildState(PrayerCycleEngine engine) {
    final today = _dateOnly(engine.now);
    final isViewingToday =
        _selectedDate == null || _sameDate(_selectedDate!, today);
    return PrayerState.fromEngine(
      engine,
      displayedDate: isViewingToday ? today : _selectedDate ?? today,
      displayedPrayers: isViewingToday
          ? engine.todayPrayers
          : _selectedDatePrayers,
      isViewingToday: isViewingToday,
      isDateNavigationBusy: _isBusy,
    );
  }

  Future<void> refreshSelectedDate() async {
    final date = _selectedDate;
    if (date == null) return;
    final result = await _getPrayerTimesByDate(date);
    result.fold(
      (f) => debugPrint('[DateNav] refresh failed: $f'),
      (prayers) => _selectedDatePrayers = prayers,
    );
  }

  Future<void> changeDate(DateTime now, int dayOffset) async {
    if (_isBusy) return;
    final today = _dateOnly(now);
    final baseDate = _selectedDate ?? today;
    final targetDate = _dateOnly(baseDate.add(Duration(days: dayOffset)));
    if (_sameDate(targetDate, today)) {
      clear();
      return;
    }
    _isBusy = true;
    final result = await _getPrayerTimesByDate(targetDate);
    result.fold((f) => debugPrint('[DateNav] load $targetDate failed: $f'), (prayers) {
      if (prayers != null) {
        _selectedDate = targetDate;
        _selectedDatePrayers = prayers;
      }
    });
    _isBusy = false;
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
