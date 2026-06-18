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
  final String nextPrayerKey;
  final bool isAdhanPlaying;
  final String currentAdhanPrayerKey;
  final String activeCyclePrayerKey;
  final bool isIqamaCountdown;
  final Duration iqamaCountdown;
  final String iqamaPrayerKey;
  final bool isIqamaPlaying;
  final bool isDuaPlaying;
  final bool isQuranPlaying;
  final bool quranUserEnabled;
  final bool isQuranPausedByUser;
  final bool isTakbeeratPlaying;
  final bool takbeeratUserEnabled;
  final bool isCycleActive;
  final bool isPrePrayerAlert;
  final bool isInPostIqamaPrayer;
  final bool isAfterPrayerAdhkarPlaying;
  final bool isSessionAdhkarPlaying;
  final bool isAdhkarSequenceActive;
  final String sessionAdhkarCategory;
  final bool isViewingToday;
  final bool isDateNavigationBusy;
  final bool isMultiCity;
  final List<String> availableCities;
  final int? currentSurahNumber;

  const PrayerState({
    required this.now,
    this.todayPrayers,
    required this.displayedDate,
    this.displayedPrayers,
    required this.countdown,
    required this.nextPrayerKey,
    required this.isAdhanPlaying,
    required this.currentAdhanPrayerKey,
    required this.activeCyclePrayerKey,
    required this.isIqamaCountdown,
    required this.iqamaCountdown,
    required this.iqamaPrayerKey,
    required this.isIqamaPlaying,
    required this.isDuaPlaying,
    required this.isQuranPlaying,
    required this.quranUserEnabled,
    required this.isQuranPausedByUser,
    required this.isTakbeeratPlaying,
    required this.takbeeratUserEnabled,
    required this.isCycleActive,
    required this.isPrePrayerAlert,
    required this.isInPostIqamaPrayer,
    required this.isAfterPrayerAdhkarPlaying,
    required this.isSessionAdhkarPlaying,
    required this.isAdhkarSequenceActive,
    required this.sessionAdhkarCategory,
    required this.isViewingToday,
    required this.isDateNavigationBusy,
    required this.isMultiCity,
    required this.availableCities,
    this.currentSurahNumber,
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
    nextPrayerKey: e.nextPrayerKey,
    isAdhanPlaying: e.isAdhanPlaying,
    currentAdhanPrayerKey: e.currentAdhanPrayerKey,
    activeCyclePrayerKey: e.activeCyclePrayerKey,
    isIqamaCountdown: e.isIqamaCountdown,
    iqamaCountdown: e.iqamaCountdown,
    iqamaPrayerKey: e.iqamaPrayerKey,
    isIqamaPlaying: e.isIqamaPlaying,
    isDuaPlaying: e.isDuaPlaying,
    isQuranPlaying: e.isQuranPlaying,
    quranUserEnabled: e.quranUserEnabled,
    isQuranPausedByUser: e.isQuranPausedByUser,
    isTakbeeratPlaying: e.isTakbeeratPlaying,
    takbeeratUserEnabled: e.takbeeratUserEnabled,
    isCycleActive: e.isCycleActive,
    isPrePrayerAlert: e.isPrePrayerAlert,
    isInPostIqamaPrayer: e.isInPostIqamaPrayer,
    isAfterPrayerAdhkarPlaying: e.isAfterPrayerAdhkarPlaying,
    isSessionAdhkarPlaying: e.isSessionAdhkarPlaying,
    isAdhkarSequenceActive: e.isAdhkarSequenceActive,
    sessionAdhkarCategory: e.sessionAdhkarCategory,
    isViewingToday: isViewingToday,
    isDateNavigationBusy: isDateNavigationBusy,
    isMultiCity: e.isMultiCity,
    availableCities: e.availableCities,
    currentSurahNumber: e.currentSurahNumber,
  );

  factory PrayerState.initial() => PrayerState(
    now: DateTime.now(),
    todayPrayers: null,
    displayedDate: DateTime.now(),
    displayedPrayers: null,
    countdown: Duration.zero,
    nextPrayerKey: '',
    isAdhanPlaying: false,
    currentAdhanPrayerKey: '',
    activeCyclePrayerKey: '',
    isIqamaCountdown: false,
    iqamaCountdown: Duration.zero,
    iqamaPrayerKey: '',
    isIqamaPlaying: false,
    isDuaPlaying: false,
    isQuranPlaying: false,
    quranUserEnabled: false,
    isQuranPausedByUser: false,
    isTakbeeratPlaying: false,
    takbeeratUserEnabled: false,
    isCycleActive: false,
    isPrePrayerAlert: false,
    isInPostIqamaPrayer: false,
    isAfterPrayerAdhkarPlaying: false,
    isSessionAdhkarPlaying: false,
    isAdhkarSequenceActive: false,
    sessionAdhkarCategory: '',
    isViewingToday: true,
    isDateNavigationBusy: false,
    isMultiCity: false,
    availableCities: const [],
  );
}
