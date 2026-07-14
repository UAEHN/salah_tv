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
import 'package:ghasaq/features/settings/domain/entities/prayer_sound_mode.dart';

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

class _RecordingAudioPort extends NoOpPrayerAudioPort {
  final List<String> announcements = [];
  @override
  Future<void> playPrayerAnnouncement(String prayerKey) async {
    announcements.add(prayerKey);
  }
}

/// Next prayer (dhuhr) is ~3s away — inside the 5s pre-announcement window.
DailyPrayerTimes _dayWithDhuhrIn3s(DateTime base) => DailyPrayerTimes(
      date: DateTime(base.year, base.month, base.day),
      fajr: base.subtract(const Duration(hours: 5)),
      sunrise: base.subtract(const Duration(hours: 4, minutes: 30)),
      dhuhr: base.add(const Duration(seconds: 3)),
      asr: base.add(const Duration(hours: 3)),
      maghrib: base.add(const Duration(hours: 6)),
      isha: base.add(const Duration(hours: 9)),
    );

PrayerCycleEngine _engine(PrayerSoundMode adhanMode, _RecordingAudioPort audio) {
  return PrayerCycleEngine(
    _FakeRepo(_dayWithDhuhrIn3s(DateTime.now())),
    audio,
    NoOpTakbeeratAudioPort(),
    AppSettings(adhanMode: adhanMode),
    () {},
  );
}

void main() {
  group('pre-adhan announcement follows the adhan sound mode', () {
    test('sound mode → announcement plays', () {
      fakeAsync((async) {
        final audio = _RecordingAudioPort();
        final engine = _engine(PrayerSoundMode.sound, audio);
        engine.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(audio.announcements, contains('dhuhr'));
        engine.dispose();
      });
    });

    test('silent mode → NO announcement', () {
      fakeAsync((async) {
        final audio = _RecordingAudioPort();
        final engine = _engine(PrayerSoundMode.silent, audio);
        engine.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(audio.announcements, isEmpty);
        engine.dispose();
      });
    });

    test('off mode → NO announcement', () {
      fakeAsync((async) {
        final audio = _RecordingAudioPort();
        final engine = _engine(PrayerSoundMode.off, audio);
        engine.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(audio.announcements, isEmpty);
        engine.dispose();
      });
    });
  });
}
