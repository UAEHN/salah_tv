import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import '../domain/i_prayer_times_repository.dart';
import '../domain/entities/daily_prayer_times.dart';
import 'sqlite_prayer_repository.dart';
import 'calculated_prayer_repository.dart';

/// Routes prayer-time lookups to either [SqlitePrayerRepository] (bundled DB)
/// or [CalculatedPrayerRepository] (adhan_dart) depending on current mode.
///
/// The engine and BLoC interact only with [IPrayerTimesRepository];
/// they never need to know which concrete source is active.
class CompositePrayerRepository implements IPrayerTimesRepository {
  CompositePrayerRepository(this._sqliteRepo, this._calcRepo);

  final SqlitePrayerRepository _sqliteRepo;
  final CalculatedPrayerRepository _calcRepo;
  bool _isCalculatedMode = false;

  IPrayerTimesRepository get _active =>
      _isCalculatedMode ? _calcRepo : _sqliteRepo;

  bool get isCalculatedMode => _isCalculatedMode;

  SqlitePrayerRepository get sqliteRepo => _sqliteRepo;

  CalculatedPrayerRepository get calcRepo => _calcRepo;

  void setMode({required bool isCalculated}) {
    _isCalculatedMode = isCalculated;
  }

  @override
  void configureCalculatedMode(
    double lat,
    double lng,
    String methodKey, {
    String madhabKey = 'shafi',
    String cityLabel = '',
    double? utcOffsetHours,
  }) {
    _calcRepo.configureCalculatedMode(
      lat, lng, methodKey,
      madhabKey: madhabKey,
      cityLabel: cityLabel,
      utcOffsetHours: utcOffsetHours,
    );
    _isCalculatedMode = true;
  }

  @override
  void configureDatabaseMode() {
    _isCalculatedMode = false;
  }

  @override
  bool get hasData => _active.hasData;

  @override
  bool get isMultiCity => _active.isMultiCity;

  @override
  List<String> get availableCities => _active.availableCities;

  @override
  String get activeCity => _active.activeCity;

  @override
  int get totalDays => _active.totalDays;

  @override
  Future<Either<Failure, Success>> initialize(String countryKey) =>
      _active.initialize(countryKey);

  @override
  Future<Either<Failure, Success>> loadCountry(String countryKey) =>
      _active.loadCountry(countryKey);

  @override
  Future<Either<Failure, DailyPrayerTimes?>> getByDate(DateTime date) =>
      _active.getByDate(date);

  @override
  void setActiveCity(String city) => _active.setActiveCity(city);

  @override
  DailyPrayerTimes? getToday() => _active.getToday();

  @override
  DailyPrayerTimes? getTomorrowByKey(String key) =>
      _active.getTomorrowByKey(key);
}
