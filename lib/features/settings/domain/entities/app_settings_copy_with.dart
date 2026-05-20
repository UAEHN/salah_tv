import '../../../quran/domain/entities/quran_playback_mode.dart';
import 'app_settings.dart';
import 'custom_adhan.dart';
import 'prayer_sound_mode.dart';

/// Extension that provides [copyWith] for [AppSettings].
///
/// Separated to keep the entity file under 150 lines.
/// [Map] fields use [Map.unmodifiable] per CLAUDE.md immutability rule.
extension AppSettingsCopyWith on AppSettings {
  AppSettings copyWith({
    String? themeColorKey,
    bool? use24HourFormat,
    PrayerSoundMode? adhanMode,
    PrayerSoundMode? iqamaMode,
    bool? isMosqueMode,
    bool? isDarkMode,
    Map<String, int>? iqamaDelays,
    Map<String, int>? adhanOffsets,
    String? hadithText,
    String? hadithSource,
    String? fontFamily,
    String? locale,
    bool? isQuranEnabled,
    String? quranReciterName,
    String? quranReciterServerUrl,
    List<String>? favoriteReciterServerUrls,
    String? selectedCountry,
    String? selectedCity,
    double? selectedLatitude,
    double? selectedLongitude,
    String? calculationMethod,
    String? madhab,
    bool? isCalculatedLocation,
    String? selectedTimeZoneId,
    bool clearSelectedTimeZoneId = false,
    double? utcOffsetHours,
    bool clearUtcOffset = false,
    String? layoutStyle,
    String? adhanSound,
    List<CustomAdhan>? customAdhans,
    bool? isAnalogClock,
    bool? isAdhkarEnabled,
    Map<String, bool>? prayerNotificationEnabled,
    Map<String, bool>? preAdhanReminderEnabled,
    int? preAdhanReminderMinutes,
    Map<String, bool>? iqamaNotificationEnabled,
    Map<String, bool>? preIqamaReminderEnabled,
    int? preIqamaReminderMinutes,
    bool? isMorningAdhkarNotificationEnabled,
    bool? isEveningAdhkarNotificationEnabled,
    int? morningAdhkarMinuteOfDay,
    int? eveningAdhkarMinuteOfDay,
    bool? isNotificationOnboardingDone,
    QuranPlaybackMode? quranPlaybackMode,
    int? selectedSurahNumber,
    bool clearSelectedSurahNumber = false,
    List<int>? surahPlaylist,
    int? surahRepeatCount,
    int? playlistCycleCount,
    ContinuousStartMode? continuousStartMode,
    int? lastPlayedSurah,
  }) {
    return AppSettings(
      themeColorKey: themeColorKey ?? this.themeColorKey,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      adhanMode: adhanMode ?? this.adhanMode,
      iqamaMode: iqamaMode ?? this.iqamaMode,
      isMosqueMode: isMosqueMode ?? this.isMosqueMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      iqamaDelays: Map.unmodifiable(iqamaDelays ?? this.iqamaDelays),
      adhanOffsets: Map.unmodifiable(adhanOffsets ?? this.adhanOffsets),
      prayerNotificationEnabled: Map.unmodifiable(
        prayerNotificationEnabled ?? this.prayerNotificationEnabled,
      ),
      preAdhanReminderEnabled: Map.unmodifiable(
        preAdhanReminderEnabled ?? this.preAdhanReminderEnabled,
      ),
      iqamaNotificationEnabled: Map.unmodifiable(
        iqamaNotificationEnabled ?? this.iqamaNotificationEnabled,
      ),
      preIqamaReminderEnabled: Map.unmodifiable(
        preIqamaReminderEnabled ?? this.preIqamaReminderEnabled,
      ),
      hadithText: hadithText ?? this.hadithText,
      hadithSource: hadithSource ?? this.hadithSource,
      fontFamily: fontFamily ?? this.fontFamily,
      locale: locale ?? this.locale,
      isQuranEnabled: isQuranEnabled ?? this.isQuranEnabled,
      quranReciterName: quranReciterName ?? this.quranReciterName,
      quranReciterServerUrl:
          quranReciterServerUrl ?? this.quranReciterServerUrl,
      favoriteReciterServerUrls: List.unmodifiable(
        favoriteReciterServerUrls ?? this.favoriteReciterServerUrls,
      ),
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedLatitude: selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: selectedLongitude ?? this.selectedLongitude,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      isCalculatedLocation: isCalculatedLocation ?? this.isCalculatedLocation,
      selectedTimeZoneId: clearSelectedTimeZoneId
          ? null
          : (selectedTimeZoneId ?? this.selectedTimeZoneId),
      utcOffsetHours: clearUtcOffset
          ? null
          : (utcOffsetHours ?? this.utcOffsetHours),
      layoutStyle: layoutStyle ?? this.layoutStyle,
      adhanSound: adhanSound ?? this.adhanSound,
      customAdhans: List.unmodifiable(customAdhans ?? this.customAdhans),
      isAnalogClock: isAnalogClock ?? this.isAnalogClock,
      isAdhkarEnabled: isAdhkarEnabled ?? this.isAdhkarEnabled,
      preAdhanReminderMinutes:
          preAdhanReminderMinutes ?? this.preAdhanReminderMinutes,
      preIqamaReminderMinutes:
          preIqamaReminderMinutes ?? this.preIqamaReminderMinutes,
      isMorningAdhkarNotificationEnabled: isMorningAdhkarNotificationEnabled ??
          this.isMorningAdhkarNotificationEnabled,
      isEveningAdhkarNotificationEnabled: isEveningAdhkarNotificationEnabled ??
          this.isEveningAdhkarNotificationEnabled,
      morningAdhkarMinuteOfDay:
          morningAdhkarMinuteOfDay ?? this.morningAdhkarMinuteOfDay,
      eveningAdhkarMinuteOfDay:
          eveningAdhkarMinuteOfDay ?? this.eveningAdhkarMinuteOfDay,
      isNotificationOnboardingDone:
          isNotificationOnboardingDone ?? this.isNotificationOnboardingDone,
      quranPlaybackMode: quranPlaybackMode ?? this.quranPlaybackMode,
      selectedSurahNumber: clearSelectedSurahNumber
          ? null
          : (selectedSurahNumber ?? this.selectedSurahNumber),
      surahPlaylist: List.unmodifiable(surahPlaylist ?? this.surahPlaylist),
      surahRepeatCount: surahRepeatCount ?? this.surahRepeatCount,
      playlistCycleCount: playlistCycleCount ?? this.playlistCycleCount,
      continuousStartMode: continuousStartMode ?? this.continuousStartMode,
      lastPlayedSurah: lastPlayedSurah ?? this.lastPlayedSurah,
    );
  }

  /// True when only UI-cosmetic fields differ (theme, font, layout, clock).
  /// False when any field consumed by [PrayerCycleEngine] has changed.
  bool prayerFieldsEqual(AppSettings other) =>
      selectedCountry == other.selectedCountry &&
      selectedCity == other.selectedCity &&
      selectedLatitude == other.selectedLatitude &&
      selectedLongitude == other.selectedLongitude &&
      calculationMethod == other.calculationMethod &&
      madhab == other.madhab &&
      isCalculatedLocation == other.isCalculatedLocation &&
      selectedTimeZoneId == other.selectedTimeZoneId &&
      utcOffsetHours == other.utcOffsetHours &&
      adhanMode == other.adhanMode &&
      iqamaMode == other.iqamaMode &&
      isMosqueMode == other.isMosqueMode &&
      adhanSound == other.adhanSound &&
      isQuranEnabled == other.isQuranEnabled &&
      quranReciterServerUrl == other.quranReciterServerUrl &&
      isAdhkarEnabled == other.isAdhkarEnabled &&
      iqamaDelays.toString() == other.iqamaDelays.toString() &&
      adhanOffsets.toString() == other.adhanOffsets.toString() &&
      prayerNotificationEnabled.toString() ==
          other.prayerNotificationEnabled.toString() &&
      preAdhanReminderEnabled.toString() ==
          other.preAdhanReminderEnabled.toString() &&
      iqamaNotificationEnabled.toString() ==
          other.iqamaNotificationEnabled.toString() &&
      preIqamaReminderEnabled.toString() ==
          other.preIqamaReminderEnabled.toString() &&
      preAdhanReminderMinutes == other.preAdhanReminderMinutes &&
      preIqamaReminderMinutes == other.preIqamaReminderMinutes &&
      isMorningAdhkarNotificationEnabled ==
          other.isMorningAdhkarNotificationEnabled &&
      isEveningAdhkarNotificationEnabled ==
          other.isEveningAdhkarNotificationEnabled &&
      morningAdhkarMinuteOfDay == other.morningAdhkarMinuteOfDay &&
      eveningAdhkarMinuteOfDay == other.eveningAdhkarMinuteOfDay &&
      isNotificationOnboardingDone == other.isNotificationOnboardingDone &&
      quranPlaybackMode == other.quranPlaybackMode &&
      selectedSurahNumber == other.selectedSurahNumber &&
      surahPlaylist.toString() == other.surahPlaylist.toString() &&
      surahRepeatCount == other.surahRepeatCount &&
      playlistCycleCount == other.playlistCycleCount &&
      continuousStartMode == other.continuousStartMode &&
      lastPlayedSurah == other.lastPlayedSurah;
}
