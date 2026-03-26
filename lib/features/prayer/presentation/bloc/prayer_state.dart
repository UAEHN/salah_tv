import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/prayer_cycle_engine.dart';

/// Immutable snapshot of all prayer-cycle state, emitted by [PrayerBloc].
/// Updated at 1 Hz (every engine tick) and on every user-initiated event.
class PrayerState {
  final DateTime now;
  final DailyPrayerTimes? todayPrayers;
  final DateTime displayedDate;
  final DailyPrayerTimes? displayedPrayers;
  final Duration countdown;
  final String nextPrayerName;
  final String nextPrayerKey;
  final bool isAdhanPlaying;
  final String currentAdhanPrayerName;
  final String activeCyclePrayerKey;
  final bool isIqamaCountdown;
  final Duration iqamaCountdown;
  final String iqamaPrayerName;
  final bool isIqamaPlaying;
  final bool isDuaPlaying;
  final bool isQuranPlaying;
  final bool quranUserEnabled;
  final bool isCycleActive;
  final bool isPrePrayerAlert;
  final bool isViewingToday;
  final bool isDateNavigationBusy;
  final bool isMultiCity;
  final List<String> availableCities;

  const PrayerState({
    required this.now,
    this.todayPrayers,
    required this.displayedDate,
    this.displayedPrayers,
    required this.countdown,
    required this.nextPrayerName,
    required this.nextPrayerKey,
    required this.isAdhanPlaying,
    required this.currentAdhanPrayerName,
    required this.activeCyclePrayerKey,
    required this.isIqamaCountdown,
    required this.iqamaCountdown,
    required this.iqamaPrayerName,
    required this.isIqamaPlaying,
    required this.isDuaPlaying,
    required this.isQuranPlaying,
    required this.quranUserEnabled,
    required this.isCycleActive,
    required this.isPrePrayerAlert,
    required this.isViewingToday,
    required this.isDateNavigationBusy,
    required this.isMultiCity,
    required this.availableCities,
  });

  factory PrayerState.fromEngine(
    PrayerCycleEngine e, {
    DateTime? displayedDate,
    DailyPrayerTimes? displayedPrayers,
    bool isViewingToday = true,
    bool isDateNavigationBusy = false,
  }) => PrayerState(
    now: e.now,
    todayPrayers: e.todayPrayers,
    displayedDate:
        displayedDate ?? DateTime(e.now.year, e.now.month, e.now.day),
    displayedPrayers: displayedPrayers ?? e.todayPrayers,
    countdown: e.countdown,
    nextPrayerName: e.nextPrayerName,
    nextPrayerKey: e.nextPrayerKey,
    isAdhanPlaying: e.isAdhanPlaying,
    currentAdhanPrayerName: e.currentAdhanPrayerName,
    activeCyclePrayerKey: e.activeCyclePrayerKey,
    isIqamaCountdown: e.isIqamaCountdown,
    iqamaCountdown: e.iqamaCountdown,
    iqamaPrayerName: e.iqamaPrayerName,
    isIqamaPlaying: e.isIqamaPlaying,
    isDuaPlaying: e.isDuaPlaying,
    isQuranPlaying: e.isQuranPlaying,
    quranUserEnabled: e.quranUserEnabled,
    isCycleActive: e.isCycleActive,
    isPrePrayerAlert: e.isPrePrayerAlert,
    isViewingToday: isViewingToday,
    isDateNavigationBusy: isDateNavigationBusy,
    isMultiCity: e.isMultiCity,
    availableCities: e.availableCities,
  );

  factory PrayerState.initial() => PrayerState(
    now: DateTime.now(),
    todayPrayers: null,
    displayedDate: DateTime.now(),
    displayedPrayers: null,
    countdown: Duration.zero,
    nextPrayerName: '',
    nextPrayerKey: '',
    isAdhanPlaying: false,
    currentAdhanPrayerName: '',
    activeCyclePrayerKey: '',
    isIqamaCountdown: false,
    iqamaCountdown: Duration.zero,
    iqamaPrayerName: '',
    isIqamaPlaying: false,
    isDuaPlaying: false,
    isQuranPlaying: false,
    quranUserEnabled: false,
    isCycleActive: false,
    isPrePrayerAlert: false,
    isViewingToday: true,
    isDateNavigationBusy: false,
    isMultiCity: false,
    availableCities: const [],
  );
}
