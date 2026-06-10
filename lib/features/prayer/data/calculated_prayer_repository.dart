import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import '../domain/i_prayer_times_repository.dart';
import '../domain/entities/daily_prayer_times.dart';
import '../domain/prayer_time_calculator.dart' as calc;
import 'adhan_calculation_source.dart';
import 'calculated_prayer_cache.dart';

/// [IPrayerTimesRepository] backed by astronomical calculation (adhan_dart).
///
/// Used for cities that are NOT in the bundled SQLite prayer-time database.
/// Provides the same interface as [SqlitePrayerRepository] so the engine
/// and BLoC remain unaware of the data source.
class CalculatedPrayerRepository implements IPrayerTimesRepository {
  CalculatedPrayerRepository(this._source);

  final AdhanCalculationSource _source;
  final CalculatedPrayerCache _cache = CalculatedPrayerCache();

  double _lat = 0;
  double _lng = 0;
  String _methodKey = 'muslim_world_league';
  String _madhabKey = 'shafi';
  String _highLatRuleKey = 'auto';
  String? _timeZoneId;
  double? _utcOffsetHours;
  String _cityLabel = '';
  bool _isInitialized = false;

  @override
  bool get hasData => _isInitialized && _cache.isNotEmpty;

  @override
  bool get isMultiCity => false;

  @override
  List<String> get availableCities =>
      _cityLabel.isNotEmpty ? [_cityLabel] : const [];

  @override
  String get activeCity => _cityLabel;

  @override
  int get totalDays => 365;

  /// Not meaningful for calculated mode — always succeeds.
  @override
  Future<Either<Failure, Success>> initialize(String countryKey) async {
    return const Right(Success());
  }

  @override
  void configureCalculatedMode(
    double lat,
    double lng,
    String methodKey, {
    String madhabKey = 'shafi',
    String highLatitudeRuleKey = 'auto',
    String cityLabel = '',
    String? timeZoneId,
    double? utcOffsetHours,
  }) {
    _lat = lat;
    _lng = lng;
    _methodKey = methodKey;
    _madhabKey = madhabKey;
    _highLatRuleKey = highLatitudeRuleKey;
    _timeZoneId = timeZoneId;
    _utcOffsetHours = utcOffsetHours;
    _cityLabel = cityLabel;
    _isInitialized = true;
    _cache.refresh(
      _source,
      _lat,
      _lng,
      _methodKey,
      madhabKey: _madhabKey,
      highLatitudeRuleKey: _highLatRuleKey,
      timeZoneId: _timeZoneId,
      utcOffsetHours: _utcOffsetHours,
    );
  }

  /// No-op: calculated repo is always in calculated mode.
  @override
  void configureDatabaseMode() {}

  /// Not meaningful for calculated mode — coordinates are set via
  /// [configureCalculatedMode]. Always returns success.
  @override
  Future<Either<Failure, Success>> loadCountry(String countryKey) async {
    return const Right(Success());
  }

  @override
  void setActiveCity(String city) {
    _cityLabel = city;
  }

  @override
  Future<Either<Failure, DailyPrayerTimes?>> getByDate(DateTime date) async {
    try {
      if (!_isInitialized) return const Right(null);
      final key = calc.dateKey(date);
      final cached = _cache.getByKey(key);
      if (cached != null) return Right(cached);
      final fresh = _source.calculateForDate(
        _lat,
        _lng,
        date,
        _methodKey,
        madhabKey: _madhabKey,
        highLatitudeRuleKey: _highLatRuleKey,
        timeZoneId: _timeZoneId,
        utcOffsetHours: _utcOffsetHours,
      );
      if (!AdhanCalculationSource.isValid(fresh)) {
        // Calculation went non-monotonic (extreme latitude edge case).
        // Fall back to yesterday's times — preferable to passing
        // garbage to the prayer cycle.
        final yesterday = _source.calculateForDate(
          _lat,
          _lng,
          date.subtract(const Duration(days: 1)),
          _methodKey,
          madhabKey: _madhabKey,
          highLatitudeRuleKey: 'middle_of_the_night',
          timeZoneId: _timeZoneId,
          utcOffsetHours: _utcOffsetHours,
        );
        return Right(yesterday);
      }
      return Right(fresh);
    } catch (e) {
      return Left(
        CacheFailure('Failed to calculate prayer times for date: $e'),
      );
    }
  }

  @override
  DailyPrayerTimes? getToday() {
    if (_cache.isStale(
      timeZoneId: _timeZoneId,
      utcOffsetHours: _utcOffsetHours,
    )) {
      _cache.refresh(
        _source,
        _lat,
        _lng,
        _methodKey,
        madhabKey: _madhabKey,
        highLatitudeRuleKey: _highLatRuleKey,
        timeZoneId: _timeZoneId,
        utcOffsetHours: _utcOffsetHours,
      );
    }
    return _cache.getToday(
      timeZoneId: _timeZoneId,
      utcOffsetHours: _utcOffsetHours,
    );
  }

  @override
  DailyPrayerTimes? getTomorrowByKey(String key) => _cache.getByKey(key);
}
