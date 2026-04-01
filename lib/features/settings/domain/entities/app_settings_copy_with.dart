import 'app_settings.dart';

/// Extension that provides [copyWith] for [AppSettings].
///
/// Separated to keep the entity file under 150 lines.
/// [Map] fields use [Map.unmodifiable] per CLAUDE.md immutability rule.
extension AppSettingsCopyWith on AppSettings {
  AppSettings copyWith({
    String? themeColorKey,
    bool? use24HourFormat,
    bool? playAdhan,
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
    String? selectedCountry,
    String? selectedCity,
    double? selectedLatitude,
    double? selectedLongitude,
    String? calculationMethod,
    String? madhab,
    bool? isCalculatedLocation,
    double? utcOffsetHours,
    bool clearUtcOffset = false,
    String? layoutStyle,
    String? adhanSound,
    bool? isAnalogClock,
    bool? isAdhkarEnabled,
    Map<String, bool>? prayerNotificationEnabled,
    Map<String, bool>? preAdhanReminderEnabled,
    int? preAdhanReminderMinutes,
    Map<String, bool>? iqamaNotificationEnabled,
    Map<String, bool>? preIqamaReminderEnabled,
    int? preIqamaReminderMinutes,
  }) {
    return AppSettings(
      themeColorKey: themeColorKey ?? this.themeColorKey,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      playAdhan: playAdhan ?? this.playAdhan,
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
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedLatitude: selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: selectedLongitude ?? this.selectedLongitude,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      isCalculatedLocation: isCalculatedLocation ?? this.isCalculatedLocation,
      utcOffsetHours: clearUtcOffset
          ? null
          : (utcOffsetHours ?? this.utcOffsetHours),
      layoutStyle: layoutStyle ?? this.layoutStyle,
      adhanSound: adhanSound ?? this.adhanSound,
      isAnalogClock: isAnalogClock ?? this.isAnalogClock,
      isAdhkarEnabled: isAdhkarEnabled ?? this.isAdhkarEnabled,
      preAdhanReminderMinutes:
          preAdhanReminderMinutes ?? this.preAdhanReminderMinutes,
      preIqamaReminderMinutes:
          preIqamaReminderMinutes ?? this.preIqamaReminderMinutes,
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
      utcOffsetHours == other.utcOffsetHours &&
      playAdhan == other.playAdhan &&
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
      preIqamaReminderMinutes == other.preIqamaReminderMinutes;
}
