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
  final String quranReciterName; // Display name (Arabic)
  final String quranReciterServerUrl; // CDN URL ending with '/'

  // Country & city selection (for multi-city CSV files)
  final String selectedCountry;
  final String selectedCity;

  // Layout style ('classic' or 'modern')
  final String layoutStyle;

  // Adhan sound selection ('default' or 'raad_al_kurdi')
  final String adhanSound;

  // Clock display style
  final bool isAnalogClock;

  // Adhkar display (أذكار الصباح والمساء)
  final bool isAdhkarEnabled;

  const AppSettings({
    this.themeColorKey = 'green',
    this.use24HourFormat = false,
    this.playAdhan = true,
    this.isDarkMode = false,
    this.fontFamily = 'Kufi',
    this.selectedCountry = 'UAE',
    this.selectedCity = 'Dubai',
    this.layoutStyle = 'modern',
    this.adhanSound = 'default',
    this.isAnalogClock = false,
    this.isAdhkarEnabled = true,
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
    String? layoutStyle,
    String? adhanSound,
    bool? isAnalogClock,
    bool? isAdhkarEnabled,
  }) {
    return AppSettings(
      themeColorKey: themeColorKey ?? this.themeColorKey,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      playAdhan: playAdhan ?? this.playAdhan,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      iqamaDelays: Map.unmodifiable(iqamaDelays ?? this.iqamaDelays),
      adhanOffsets: Map.unmodifiable(adhanOffsets ?? this.adhanOffsets),
      hadithText: hadithText ?? this.hadithText,
      hadithSource: hadithSource ?? this.hadithSource,
      fontFamily: fontFamily ?? this.fontFamily,
      isQuranEnabled: isQuranEnabled ?? this.isQuranEnabled,
      quranReciterName: quranReciterName ?? this.quranReciterName,
      quranReciterServerUrl:
          quranReciterServerUrl ?? this.quranReciterServerUrl,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCity: selectedCity ?? this.selectedCity,
      layoutStyle: layoutStyle ?? this.layoutStyle,
      adhanSound: adhanSound ?? this.adhanSound,
      isAnalogClock: isAnalogClock ?? this.isAnalogClock,
      isAdhkarEnabled: isAdhkarEnabled ?? this.isAdhkarEnabled,
    );
  }
}
