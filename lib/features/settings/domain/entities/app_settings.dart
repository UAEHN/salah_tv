class AppSettings {
  final String themeColorKey;
  final bool use24HourFormat;
  final bool playAdhan;
  final bool isDarkMode;
  final Map<String, int> iqamaDelays;
  final Map<String, int> adhanOffsets;
  final String hadithText;
  final String hadithSource;
  final String fontFamily;

  // Quran background audio (streamed from mp3quran.net API)
  final bool isQuranEnabled;
  final String quranReciterName;
  final String quranReciterServerUrl;

  // Country & city selection (for multi-city CSV files)
  final String selectedCountry;
  final String selectedCity;

  // Worldwide location (mobile only — when city is not in bundled DB)
  final double? selectedLatitude;
  final double? selectedLongitude;
  final String calculationMethod;
  final String madhab; // 'shafi' | 'hanafi'
  final bool isCalculatedLocation;

  /// UTC offset (hours) of the selected city. Used to display prayer times
  /// in the city's local timezone instead of device timezone. Null means
  /// use device local timezone (e.g. GPS-detected location where user is).
  final double? utcOffsetHours;

  final String layoutStyle;
  final String adhanSound;
  final bool isAnalogClock;
  final bool isAdhkarEnabled;

  // ── Notification settings (mobile only) ─────────────────────────────────
  final Map<String, bool> prayerNotificationEnabled;
  final Map<String, bool> preAdhanReminderEnabled;
  final int preAdhanReminderMinutes;
  final Map<String, bool> iqamaNotificationEnabled;
  final Map<String, bool> preIqamaReminderEnabled;
  final int preIqamaReminderMinutes;

  const AppSettings({
    this.themeColorKey = 'green',
    this.use24HourFormat = false,
    this.playAdhan = true,
    this.isDarkMode = false,
    this.fontFamily = 'Kufi',
    this.selectedCountry = 'UAE',
    this.selectedCity = 'Dubai',
    this.selectedLatitude,
    this.selectedLongitude,
    this.calculationMethod = 'muslim_world_league',
    this.madhab = 'shafi',
    this.isCalculatedLocation = false,
    this.utcOffsetHours,
    this.layoutStyle = 'modern',
    this.adhanSound = 'default',
    this.isAnalogClock = false,
    this.isAdhkarEnabled = true,
    this.preAdhanReminderMinutes = 15,
    this.iqamaDelays = const {
      'fajr': 20, 'dhuhr': 10, 'asr': 10, 'maghrib': 5, 'isha': 15,
    },
    this.adhanOffsets = const {
      'fajr': 0, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0,
    },
    this.prayerNotificationEnabled = const {
      'fajr': true, 'dhuhr': true, 'asr': true, 'maghrib': true, 'isha': true,
    },
    this.preAdhanReminderEnabled = const {
      'fajr': false, 'dhuhr': false, 'asr': false,
      'maghrib': false, 'isha': false,
    },
    this.iqamaNotificationEnabled = const {
      'fajr': false, 'dhuhr': false, 'asr': false,
      'maghrib': false, 'isha': false,
    },
    this.preIqamaReminderEnabled = const {
      'fajr': false, 'dhuhr': false, 'asr': false,
      'maghrib': false, 'isha': false,
    },
    this.preIqamaReminderMinutes = 5,
    this.hadithText =
        '"مَن صامَ رمضانَ ثمَّ أتبعَهُ ستًّا من شوَّالٍ كانَ كصيامِ الدَّهرِ"',
    this.hadithSource = 'رواه مسلم',
    this.isQuranEnabled = false,
    this.quranReciterName = '',
    this.quranReciterServerUrl = '',
  });

  bool get hasQuranReciter =>
      quranReciterServerUrl.isNotEmpty && quranReciterName.isNotEmpty;

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
      utcOffsetHours: clearUtcOffset ? null : (utcOffsetHours ?? this.utcOffsetHours),
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
}
