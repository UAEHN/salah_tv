import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/diagnostics/adhan_journey_state.dart';
import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/core/usecases/success.dart';
import 'package:ghasaq/features/analytics/domain/i_analytics_service.dart';
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

/// Adhan audio that "plays" but never signals completion — simulating the
/// engine freezing mid-adhan in the background (isAdhanPlaying stays true).
class _StuckAudioPort extends NoOpPrayerAudioPort {
  @override
  Future<bool> playAdhan({String soundKey = 'default'}) async => true;
}

/// Records only the adhan journey states; every other analytics call no-ops.
class _RecordingAnalytics implements IAnalyticsService {
  final List<String> adhanStates = [];
  @override
  void logAdhanJourneyState({
    required String prayerKey,
    required String state,
    required String stage,
    String? reason,
  }) => adhanStates.add(state);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// asr is 5s past (live fire window); other prayers far away.
DailyPrayerTimes _dayWithAsrJustPassed(DateTime base) => DailyPrayerTimes(
      date: DateTime(base.year, base.month, base.day),
      fajr: base.subtract(const Duration(hours: 8)),
      sunrise: base.subtract(const Duration(hours: 7, minutes: 30)),
      dhuhr: base.subtract(const Duration(hours: 3)),
      asr: base.subtract(const Duration(seconds: 5)),
      maghrib: base.add(const Duration(hours: 2)),
      isha: base.add(const Duration(hours: 5)),
    );

void main() {
  test(
      'returning after a background adhan froze does NOT drop the iqama '
      '(reproduces iqama_dropped_in_foreground)', () {
    fakeAsync((async) {
      final base = DateTime(2026, 7, 8, 15, 30, 0);
      final fakeNow = base;
      final analytics = _RecordingAnalytics();
      final engine = PrayerCycleEngine(
        _FakeRepo(_dayWithAsrJustPassed(base)),
        _StuckAudioPort(),
        NoOpTakbeeratAudioPort(),
        const AppSettings(), // iqamaDelays['asr'] = 10 min
        () {},
        analytics: analytics,
        clockOverride: () => fakeNow,
      );

      engine.start();
      // Fire asr's adhan, then leave it "playing" — the frozen-mid-adhan state.
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(engine.isAdhanPlaying, isTrue, reason: 'sanity: adhan frozen mid-play');
      expect(engine.s.adhansToday, contains('asr_${engine.s.now.day}'));

      // Return to the app: onResumed tears the frozen adhan down.
      engine.onResumed();

      // The iqama must be RESTORED from the adhan anchor, not dropped.
      expect(
        engine.isIqamaCountdown,
        isTrue,
        reason: 'iqama countdown restored, not dropped',
      );
      expect(engine.iqamaPrayerKey, 'asr');
      expect(
        engine.activeCyclePrayerKey,
        'asr',
        reason: 'card highlight stays consistent with the countdown (asr)',
      );
      expect(engine.isAdhanPlaying, isFalse);
      // The interrupted adhan's health-flow tracker is closed (AUDIO_COMPLETED
      // emitted) so it never times out into a false "adhan didn't finish" alarm.
      expect(
        analytics.adhanStates,
        contains(AdhanJourneyState.audioCompleted),
        reason: 'the torn-down adhan flow must be resolved, not left dangling',
      );
      engine.dispose();
    });
  });
}
