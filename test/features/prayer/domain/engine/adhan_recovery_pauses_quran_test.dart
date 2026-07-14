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

/// Repo returning a fixed day where `dhuhr` was ~6 min ago — its adhan window
/// is missed (>5 min), but its iqama (dhuhr + 10 min default) is still ahead.
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

/// Records the Quran audio calls so we can prove the recovered iqama does not
/// leave the background Quran playing on top of it.
class _RecordingAudioPort extends NoOpPrayerAudioPort {
  int pauseQuranCount = 0;
  int resumeOrRestartCount = 0;

  @override
  Future<void> pauseQuranPlayer() {
    pauseQuranCount++;
    return super.pauseQuranPlayer();
  }

  @override
  Future<void> resumeOrRestartQuranPlayer(String serverUrl) {
    resumeOrRestartCount++;
    return super.resumeOrRestartQuranPlayer(serverUrl);
  }
}

DailyPrayerTimes _dayWithDhuhr6MinAgo(DateTime base) => DailyPrayerTimes(
      date: DateTime(base.year, base.month, base.day),
      fajr: base.subtract(const Duration(hours: 5)),
      sunrise: base.subtract(const Duration(hours: 4, minutes: 30)),
      dhuhr: base.subtract(const Duration(minutes: 6)),
      asr: base.add(const Duration(hours: 3)),
      maghrib: base.add(const Duration(hours: 6)),
      isha: base.add(const Duration(hours: 9)),
    );

void main() {
  test(
      'resuming into a missed-adhan iqama window pauses the Quran instead of '
      'leaving it playing over the iqama', () {
    final audio = _RecordingAudioPort();
    final engine = PrayerCycleEngine(
      _FakeRepo(_dayWithDhuhr6MinAgo(DateTime.now())),
      audio,
      NoOpTakbeeratAudioPort(),
      const AppSettings(), // iqamaDelays['dhuhr'] = 10 min
      () {},
    );

    // User had Quran playing before backgrounding.
    engine.toggleQuran('https://server.mp3quran.net/test/');
    expect(engine.isQuranPlaying, isTrue, reason: 'sanity: Quran is on');

    // Return to the app: recovery restores the missed dhuhr's iqama countdown.
    engine.onResumed();

    expect(
      engine.isIqamaCountdown,
      isTrue,
      reason: 'the missed prayer is recovered as an iqama countdown',
    );
    expect(engine.iqamaPrayerKey, 'dhuhr');
    expect(
      engine.isQuranPlaying,
      isFalse,
      reason: 'the Quran must be paused for the recovered cycle, not audible '
          'under the iqama',
    );
    expect(
      audio.pauseQuranCount,
      greaterThanOrEqualTo(1),
      reason: 'recovery must pause the Quran player',
    );
    expect(
      audio.resumeOrRestartCount,
      0,
      reason: 'the Quran must NOT be resumed on top of the recovered iqama',
    );

    engine.dispose();
  });
}
