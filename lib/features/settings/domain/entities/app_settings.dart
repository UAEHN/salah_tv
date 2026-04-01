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
  final String locale;

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
    this.locale = 'ar',
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
      'fajr': 20,
      'dhuhr': 10,
      'asr': 10,
      'maghrib': 5,
      'isha': 15,
    },
    this.adhanOffsets = const {
      'fajr': 0,
      'sunrise': 0,
      'dhuhr': 0,
      'asr': 0,
      'maghrib': 0,
      'isha': 0,
    },
    this.prayerNotificationEnabled = const {
      'fajr': true,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    },
    this.preAdhanReminderEnabled = const {
      'fajr': false,
      'dhuhr': false,
      'asr': false,
      'maghrib': false,
      'isha': false,
    },
    this.iqamaNotificationEnabled = const {
      'fajr': false,
      'dhuhr': false,
      'asr': false,
      'maghrib': false,
      'isha': false,
    },
    this.preIqamaReminderEnabled = const {
      'fajr': false,
      'dhuhr': false,
      'asr': false,
      'maghrib': false,
      'isha': false,
    },
    this.preIqamaReminderMinutes = 5,
    this.hadithText =
        '"Whoever fasts Ramadan then follows it with six days of Shawwal, it is as if he fasted the whole year."',
    this.hadithSource = 'Sahih Muslim',
    this.isQuranEnabled = false,
    this.quranReciterName = '',
    this.quranReciterServerUrl = '',
  });

  bool get hasQuranReciter =>
      quranReciterServerUrl.isNotEmpty && quranReciterName.isNotEmpty;
}
