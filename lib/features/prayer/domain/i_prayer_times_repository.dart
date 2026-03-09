import '../../../models/daily_prayer_times.dart';

abstract class IPrayerTimesRepository {
  bool get hasData;
  bool get isMultiCity;
  List<String> get availableCities;
  String get activeCity;
  int get totalDays;

  Future<void> initialize(String countryKey);
  Future<void> loadCountry(String countryKey);
  void setActiveCity(String city);
  DailyPrayerTimes? getToday();
  DailyPrayerTimes? getTomorrowByKey(String key);
}
