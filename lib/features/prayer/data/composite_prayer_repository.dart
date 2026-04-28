import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import '../domain/i_prayer_times_repository.dart';
import '../domain/entities/daily_prayer_times.dart';
import 'downloaded_prayer_repository.dart';
import 'calculated_prayer_repository.dart';

enum _RepoMode { downloaded, calculated }

/// Routes prayer-time lookups to either [DownloadedPrayerRepository] (local
/// cache DB) or [CalculatedPrayerRepository] (adhan_dart) depending on mode.
class CompositePrayerRepository implements IPrayerTimesRepository {
  CompositePrayerRepository(this._downloadedRepo, this._calcRepo);

  final DownloadedPrayerRepository _downloadedRepo;
  final CalculatedPrayerRepository _calcRepo;
  _RepoMode _mode = _RepoMode.calculated;

  IPrayerTimesRepository get _active =>
      _mode == _RepoMode.downloaded ? _downloadedRepo : _calcRepo;

  bool get isCalculatedMode => _mode == _RepoMode.calculated;

  DownloadedPrayerRepository get downloadedRepo => _downloadedRepo;

  CalculatedPrayerRepository get calcRepo => _calcRepo;

  void setMode({required bool isCalculated}) {
    _mode = isCalculated ? _RepoMode.calculated : _RepoMode.downloaded;
  }

  @override
  void configureCalculatedMode(
    double lat,
    double lng,
    String methodKey, {
    String madhabKey = 'shafi',
    String cityLabel = '',
    String? timeZoneId,
    double? utcOffsetHours,
  }) {
    _calcRepo.configureCalculatedMode(
      lat, lng, methodKey,
      madhabKey: madhabKey,
      cityLabel: cityLabel,
      timeZoneId: timeZoneId,
      utcOffsetHours: utcOffsetHours,
    );
    _mode = _RepoMode.calculated;
  }

  @override
  void configureDatabaseMode() {
    _mode = _RepoMode.downloaded;
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
