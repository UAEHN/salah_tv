import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import 'entities/daily_prayer_times.dart';

abstract class IPrayerTimesRepository {
  bool get hasData;
  bool get isMultiCity;
  List<String> get availableCities;
  String get activeCity;
  int get totalDays;

  Future<Either<Failure, Success>> initialize(String countryKey);
  Future<Either<Failure, Success>> loadCountry(String countryKey);
  Future<Either<Failure, DailyPrayerTimes?>> getByDate(DateTime date);
  void setActiveCity(String city);
  // Sync O(1) cache lookups — no Either needed
  DailyPrayerTimes? getToday();
  DailyPrayerTimes? getTomorrowByKey(String key);
}
