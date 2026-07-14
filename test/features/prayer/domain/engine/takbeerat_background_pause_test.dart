import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/core/usecases/success.dart';
import 'package:ghasaq/features/audio/data/noop_prayer_audio_port.dart';
import 'package:ghasaq/features/audio/data/noop_takbeerat_audio_port.dart';
import 'package:ghasaq/features/prayer/domain/entities/daily_prayer_times.dart';
import 'package:ghasaq/features/prayer/domain/i_prayer_times_repository.dart';
import 'package:ghasaq/features/prayer/domain/prayer_cycle_engine.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings.dart';

class _FakeRepo implements IPrayerTimesRepository {
  _FakeRepo(this._today);
  final DailyPrayerTimes _today;

  @override
  DailyPrayerTimes? getToday() => _today;
  @override
  DailyPrayerTimes? getTomorrowByKey(String key) => null;
  @override
  bool get hasData => true;
  @override
  bool get isMultiCity => false;
  @override
  List<String> get availableCities => const [];
  @override
  String get activeCity => 'Test';
  @override
  int get totalDays => 365;
  @override
  Future<Either<Failure, Success>> initialize(String c) async =>
      const Right(Success());
  @override
  Future<Either<Failure, Success>> loadCountry(String c) async =>
      const Right(Success());
  @override
  Future<Either<Failure, DailyPrayerTimes?>> getByDate(DateTime d) async =>
      Right(_today);
  @override
  void setActiveCity(String city) {}
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
  }) {}
  @override
  void configureDatabaseMode() {}
}

class _RecordingTakbeeratPort extends NoOpTakbeeratAudioPort {
  int pauseCount = 0;
  int resumeCount = 0;
  @override
  Future<void> pause() async => pauseCount++;
  @override
  Future<void> resume() async => resumeCount++;
}

DailyPrayerTimes _quietDay(DateTime base) => DailyPrayerTimes(
      date: DateTime(base.year, base.month, base.day),
      fajr: base.subtract(const Duration(hours: 5)),
      sunrise: base.subtract(const Duration(hours: 4, minutes: 30)),
      dhuhr: base.add(const Duration(hours: 2)),
      asr: base.add(const Duration(hours: 4)),
      maghrib: base.add(const Duration(hours: 6)),
      isha: base.add(const Duration(hours: 9)),
    );

void main() {
  test('backgrounding pauses a user-enabled Takbeerat, foreground resumes it',
      () {
    final takbeerat = _RecordingTakbeeratPort();
    final engine = PrayerCycleEngine(
      _FakeRepo(_quietDay(DateTime.now())),
      NoOpPrayerAudioPort(),
      takbeerat,
      const AppSettings(),
      () {},
    );

    engine.toggleTakbeerat('https://example.test/takbeer.mp3');
    expect(engine.takbeeratUserEnabled, isTrue, reason: 'sanity: Takbeerat on');

    engine.onPaused();
    expect(takbeerat.pauseCount, 1, reason: 'background must pause Takbeerat');

    engine.onResumed();
    expect(takbeerat.resumeCount, 1, reason: 'foreground must resume Takbeerat');

    engine.dispose();
  });
}
