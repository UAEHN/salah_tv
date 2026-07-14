import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/analytics/domain/i_analytics_service.dart';
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

/// Counts only the tick-heartbeat calls; every other analytics call no-ops.
class _HeartbeatCounter implements IAnalyticsService {
  int beats = 0;
  @override
  void logTickHeartbeat({
    required String nextPrayerKey,
    required int countdownSeconds,
    required bool isCycleActive,
    required bool hasPrayerData,
    bool quranPlaying = false,
    bool takbeeratPlaying = false,
    String cyclePhase = '',
  }) => beats++;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// All prayers far from `base` so nothing fires — we only exercise the tick's
/// diagnostic heartbeat, not the cycle.
DailyPrayerTimes _quietDay(DateTime base) => DailyPrayerTimes(
      date: DateTime(base.year, base.month, base.day),
      fajr: base.subtract(const Duration(hours: 8)),
      sunrise: base.subtract(const Duration(hours: 7, minutes: 30)),
      dhuhr: base.subtract(const Duration(hours: 3)),
      asr: base.add(const Duration(hours: 2)),
      maghrib: base.add(const Duration(hours: 4)),
      isha: base.add(const Duration(hours: 6)),
    );

void main() {
  test(
      'a BACKWARD clock jump still emits the tick heartbeat (no starved '
      'countdown-stall detector → no false countdown_stall)', () {
    fakeAsync((async) {
      final base = DateTime(2026, 7, 8, 15, 30, 0);
      var fakeNow = base;
      final analytics = _HeartbeatCounter();

      final engine = PrayerCycleEngine(
        _FakeRepo(_quietDay(base)),
        NoOpPrayerAudioPort(),
        NoOpTakbeeratAudioPort(),
        const AppSettings(),
        () {},
        analytics: analytics,
        clockOverride: () => fakeNow,
      );

      engine.start();
      async.elapse(const Duration(seconds: 1)); // first heartbeat anchors
      async.flushMicrotasks();
      final beatsBefore = analytics.beats;
      expect(beatsBefore, greaterThan(0), reason: 'sanity: heartbeat armed');

      // User (or NTP) rewinds the device clock 5 minutes — same calendar day.
      // The rewind tick itself takes the time-jump branch (reload + early
      // return, before diagnostics), so the heartbeat re-anchors on the NEXT
      // normal tick — mirroring the real device.
      fakeNow = base.subtract(const Duration(minutes: 5));
      async.elapse(const Duration(seconds: 1)); // jump tick — early returns
      async.flushMicrotasks();
      fakeNow = fakeNow.add(const Duration(seconds: 1)); // normal 1s drift
      async.elapse(const Duration(seconds: 1)); // reaches the heartbeat
      async.flushMicrotasks();

      // Pre-fix: now.difference(last) was negative (< 1-min throttle) so the
      // heartbeat NEVER emitted until real time caught back up — starving the
      // countdown-stall detector into a false alarm ~150s later. Post-fix a
      // non-forward gap emits + re-anchors immediately.
      expect(
        analytics.beats,
        greaterThan(beatsBefore),
        reason: 'a backward jump must still emit a heartbeat',
      );

      engine.dispose();
    });
  });
}
