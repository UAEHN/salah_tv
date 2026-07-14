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

/// fajr long past (marked missed), dhuhr 6 min ago (its iqama is still counting
/// down → an ACTIVE cycle, which is what made recovery bail on the real device).
DailyPrayerTimes _day(DateTime base) => DailyPrayerTimes(
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
      'a same-day clock jump does NOT wipe the already-fired set — no false '
      'adhan_never_triggered storm, no re-fire', () {
    fakeAsync((async) {
      // Fixed same-day clock we fully control (mid-afternoon so dhuhr is past).
      final base = DateTime(2026, 7, 8, 15, 30, 0);
      var fakeNow = base;

      final engine = PrayerCycleEngine(
        _FakeRepo(_day(base)),
        NoOpPrayerAudioPort(),
        NoOpTakbeeratAudioPort(),
        const AppSettings(), // iqamaDelays['dhuhr'] = 10 min
        () {},
        clockOverride: () => fakeNow,
      );

      engine.start();
      final day = engine.s.now.day;
      // start() recovered the missed prayers into the fired-set and put dhuhr's
      // iqama into an active countdown — the exact state that made recovery bail.
      expect(engine.s.adhansToday, contains('dhuhr_$day'));
      expect(engine.s.adhansToday, contains('fajr_$day'));
      expect(engine.isIqamaCountdown, isTrue,
          reason: 'sanity: an active cycle is what triggered the bug');

      // A cheap-box NTP correction: +2 minutes, same calendar day.
      fakeNow = base.add(const Duration(minutes: 2));
      async.elapse(const Duration(seconds: 1)); // one tick observes the jump
      async.flushMicrotasks();

      // The fired-set must survive. Before the fix it was wiped and — because
      // recovery bails while the cycle is active — stayed empty, so the overdue
      // detector re-flagged every prayer as adhan_never_triggered.
      expect(engine.s.adhansToday, contains('dhuhr_$day'),
          reason: 'same-day jump must not wipe adhansToday');
      expect(engine.s.adhansToday, contains('fajr_$day'));

      engine.dispose();
    });
  });
}
