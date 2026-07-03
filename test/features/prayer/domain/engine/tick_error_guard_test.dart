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

/// Repo whose sync hot-path lookups throw — simulates the device-specific
/// fault that froze the live clock before the [tick] guard was added.
class _ThrowingRepo implements IPrayerTimesRepository {
  @override
  DailyPrayerTimes? getToday() => throw StateError('boom-getToday');
  @override
  DailyPrayerTimes? getTomorrowByKey(String key) => null;
  @override
  bool get hasData => false;
  @override
  bool get isMultiCity => false;
  @override
  List<String> get availableCities => const [];
  @override
  String get activeCity => 'X';
  @override
  int get totalDays => 0;
  @override
  Future<Either<Failure, Success>> initialize(String c) async =>
      const Right(Success());
  @override
  Future<Either<Failure, Success>> loadCountry(String c) async =>
      const Right(Success());
  @override
  Future<Either<Failure, DailyPrayerTimes?>> getByDate(DateTime d) async =>
      const Right(null);
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

void main() {
  test('tick keeps calling notify even when a hot-path call throws', () {
    fakeAsync((async) {
      var notifies = 0;
      final engine = PrayerCycleEngine(
        _ThrowingRepo(),
        NoOpPrayerAudioPort(),
        NoOpTakbeeratAudioPort(),
        const AppSettings(),
        () => notifies++,
      );
      // start() itself calls loadToday()/getToday() (which throws) — must not
      // bubble out and kill the timer setup.
      engine.start();
      final afterStart = notifies;
      // Drive 5 one-second ticks; each tick's body throws, but the guard must
      // still pump notify() so the clock/countdown keep updating on screen.
      async.elapse(const Duration(seconds: 5));
      expect(
        notifies - afterStart,
        greaterThanOrEqualTo(5),
        reason: 'notify must fire every tick despite the throw',
      );
      engine.dispose();
    });
  });
}
