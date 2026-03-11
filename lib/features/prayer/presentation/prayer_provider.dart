import 'package:flutter/widgets.dart';
import '../../../models/app_settings.dart';
import '../../../models/daily_prayer_times.dart';
import '../domain/i_prayer_times_repository.dart';
import '../domain/prayer_cycle_engine.dart';
import '../../audio/domain/i_audio_repository.dart';

class PrayerProvider extends ChangeNotifier with WidgetsBindingObserver {
  late final PrayerCycleEngine _engine;
  bool _disposed = false;

  PrayerProvider(
    IPrayerTimesRepository csvService,
    IAudioRepository audioService, [
    AppSettings? settings,
  ]) {
    _engine = PrayerCycleEngine(
      csvService,
      audioService,
      settings ?? const AppSettings(),
      _safeNotify,
    );
  }

  DateTime get now => _engine.now;
  DailyPrayerTimes? get todayPrayers => _engine.todayPrayers;
  Duration get countdown => _engine.countdown;
  String get nextPrayerName => _engine.nextPrayerName;
  String get nextPrayerKey => _engine.nextPrayerKey;
  bool get isAdhanPlaying => _engine.isAdhanPlaying;
  String get currentAdhanPrayerName => _engine.currentAdhanPrayerName;
  String get activeCyclePrayerKey => _engine.activeCyclePrayerKey;
  bool get isIqamaCountdown => _engine.isIqamaCountdown;
  Duration get iqamaCountdown => _engine.iqamaCountdown;
  String get iqamaPrayerName => _engine.iqamaPrayerName;
  bool get isIqamaPlaying => _engine.isIqamaPlaying;
  bool get isDuaPlaying => _engine.isDuaPlaying;
  bool get isQuranPlaying => _engine.isQuranPlaying;
  bool get quranUserEnabled => _engine.quranUserEnabled;

  void updateSettings(AppSettings settings) => _engine.updateSettings(settings);

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _engine.start();
  }

  void reload() => _engine.reload();
  void testAdhan() => _engine.testAdhan();
  void testIqama() => _engine.testIqama();
  Future<void> stopAdhan() => _engine.stopAdhan();
  Future<void> stopDua() => _engine.stopDua();
  Future<void> stopIqama() => _engine.stopIqama();
  void toggleQuran(String? serverUrl) => _engine.toggleQuran(serverUrl);

  bool get isCycleActive => _engine.isCycleActive;
  bool get isPrePrayerAlert => _engine.isPrePrayerAlert;
  void setMakkahStreamAudioActive(bool value) =>
      _engine.setMakkahStreamAudioActive(value);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _engine.onResumed();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _engine.dispose();
    super.dispose();
  }
}
