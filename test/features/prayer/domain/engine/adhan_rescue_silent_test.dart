import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/core/usecases/success.dart';
import 'package:ghasaq/features/audio/data/noop_prayer_audio_port.dart';
import 'package:ghasaq/features/audio/data/noop_takbeerat_audio_port.dart';
import 'package:ghasaq/features/prayer/domain/entities/daily_prayer_times.dart';
import 'package:ghasaq/features/prayer/domain/i_prayer_times_repository.dart';
import 'package:ghasaq/features/prayer/domain/prayer_cycle_engine.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings.dart';

/// Repo returning a fixed day. `dhuhr` is the prayer under test; the other
/// prayers sit far enough away not to interfere.
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

/// Counts the audible calls so we can assert the adhan never sounds late.
class _RecordingAudioPort extends NoOpPrayerAudioPort {
  int playAdhanCount = 0;
  int playDuaCount = 0;

  @override
  Future<bool> playAdhan({String soundKey = 'default'}) {
    playAdhanCount++;
    return super.playAdhan(soundKey: soundKey);
  }

  @override
  Future<bool> playDua() {
    playDuaCount++;
    return super.playDua();
  }
}

DailyPrayerTimes _dayWithDhuhrAt(DateTime dhuhr, DateTime base) =>
    DailyPrayerTimes(
      date: DateTime(base.year, base.month, base.day),
      fajr: base.subtract(const Duration(hours: 5)),
      sunrise: base.subtract(const Duration(hours: 4, minutes: 30)),
      dhuhr: dhuhr,
      asr: base.add(const Duration(hours: 3)),
      maghrib: base.add(const Duration(hours: 6)),
      isha: base.add(const Duration(hours: 9)),
    );

PrayerCycleEngine _engineFor(DateTime dhuhr, _RecordingAudioPort audio) {
  final base = DateTime.now();
  return PrayerCycleEngine(
    _FakeRepo(_dayWithDhuhrAt(dhuhr, base)),
    audio,
    NoOpTakbeeratAudioPort(),
    const AppSettings(), // iqamaDelays['dhuhr'] = 10 min by default
    () {},
  );
}

void main() {
  group('missed-adhan window never sounds a late call to prayer', () {
    test('within 30s (on time) → the adhan DOES sound', () {
      fakeAsync((async) {
        final audio = _RecordingAudioPort();
        // 10s past dhuhr — inside the live window.
        final engine = _engineFor(
          DateTime.now().subtract(const Duration(seconds: 10)),
          audio,
        );
        engine.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(
          audio.playAdhanCount,
          greaterThanOrEqualTo(1),
          reason: 'an on-time adhan must still sound',
        );
        engine.dispose();
      });
    });

    test('past 30s (91s late) → NO adhan, but the iqama countdown is restored',
        () {
      fakeAsync((async) {
        final audio = _RecordingAudioPort();
        // 91s past dhuhr — inside the old "rescue" window (30s–5min).
        final engine = _engineFor(
          DateTime.now().subtract(const Duration(seconds: 91)),
          audio,
        );
        engine.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(
          audio.playAdhanCount,
          0,
          reason: 'a >30s-late adhan calls people to a time that already '
              'passed — it must never sound',
        );
        expect(audio.playDuaCount, 0, reason: 'no adhan → no dua');
        expect(
          engine.isIqamaCountdown,
          isTrue,
          reason: 'the prayer is not dropped: the iqama countdown is restored',
        );
        expect(engine.iqamaPrayerKey, 'dhuhr');
        engine.dispose();
      });
    });
  });
}
