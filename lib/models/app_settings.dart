import 'dart:convert';

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

  // Makkah live stream
  final bool isMakkahStreamEnabled;
  final bool isMakkahStreamAudioEnabled; // false = muted (Quran continues)

  const AppSettings({
    this.themeColorKey = 'green',
    this.use24HourFormat = false,
    this.playAdhan = true,
    this.isDarkMode = false,
    this.fontFamily = 'Cairo',
    this.selectedCountry = 'UAE',
    this.selectedCity = 'Dubai',
    this.layoutStyle = 'modern',
    this.adhanSound = 'default',
    this.isMakkahStreamEnabled = false,
    this.isMakkahStreamAudioEnabled = false,
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

  /// Reject URLs that are not HTTPS on the trusted mp3quran.net CDN.
  static String _validatedQuranUrl(String url) {
    if (url.isEmpty) return '';
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || !uri.host.endsWith('mp3quran.net')) {
      return '';
    }
    return url;
  }

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
    bool? isMakkahStreamEnabled,
    bool? isMakkahStreamAudioEnabled,
  }) {
    return AppSettings(
      themeColorKey: themeColorKey ?? this.themeColorKey,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      playAdhan: playAdhan ?? this.playAdhan,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      iqamaDelays: iqamaDelays ?? this.iqamaDelays,
      adhanOffsets: adhanOffsets ?? this.adhanOffsets,
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
      isMakkahStreamEnabled:
          isMakkahStreamEnabled ?? this.isMakkahStreamEnabled,
      isMakkahStreamAudioEnabled:
          isMakkahStreamAudioEnabled ?? this.isMakkahStreamAudioEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
    'themeColorKey': themeColorKey,
    'use24HourFormat': use24HourFormat,
    'playAdhan': playAdhan,
    'isDarkMode': isDarkMode,
    'iqamaDelays': jsonEncode(iqamaDelays),
    'adhanOffsets': jsonEncode(adhanOffsets),
    'hadithText': hadithText,
    'hadithSource': hadithSource,
    'fontFamily': fontFamily,
    'isQuranEnabled': isQuranEnabled,
    'quranReciterName': quranReciterName,
    'quranReciterServerUrl': quranReciterServerUrl,
    'selectedCountry': selectedCountry,
    'selectedCity': selectedCity,
    'layoutStyle': layoutStyle,
    'adhanSound': adhanSound,
    'isMakkahStreamEnabled': isMakkahStreamEnabled,
    'isMakkahStreamAudioEnabled': isMakkahStreamAudioEnabled,
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    Map<String, int> delays = const {
      'fajr': 20,
      'dhuhr': 10,
      'asr': 10,
      'maghrib': 5,
      'isha': 15,
    };
    if (map['iqamaDelays'] != null) {
      try {
        final decoded = jsonDecode(map['iqamaDelays'] as String) as Map;
        delays = decoded.map((k, v) => MapEntry(k.toString(), v as int));
      } catch (_) {}
    }

    Map<String, int> offsets = const {
      'fajr': 0,
      'sunrise': 0,
      'dhuhr': 0,
      'asr': 0,
      'maghrib': 0,
      'isha': 0,
    };
    if (map['adhanOffsets'] != null) {
      try {
        final decoded = jsonDecode(map['adhanOffsets'] as String) as Map;
        offsets = decoded.map((k, v) => MapEntry(k.toString(), v as int));
      } catch (_) {}
    }

    return AppSettings(
      themeColorKey: map['themeColorKey'] as String? ?? 'green',
      use24HourFormat: map['use24HourFormat'] as bool? ?? false,
      playAdhan: map['playAdhan'] as bool? ?? true,
      isDarkMode: map['isDarkMode'] as bool? ?? false,
      iqamaDelays: delays,
      adhanOffsets: offsets,
      hadithText:
          map['hadithText'] as String? ??
          '"مَن صامَ رمضانَ ثمَّ أتبعَهُ ستًّا من شوَّالٍ كانَ كصيامِ الدَّهرِ"',
      hadithSource: map['hadithSource'] as String? ?? 'رواه مسلم',
      fontFamily:
          const ['Cairo', 'Tajawal', 'Beiruti'].contains(map['fontFamily'])
          ? map['fontFamily'] as String
          : 'Cairo',
      isQuranEnabled: map['isQuranEnabled'] as bool? ?? false,
      quranReciterName: map['quranReciterName'] as String? ?? '',
      quranReciterServerUrl: _validatedQuranUrl(map['quranReciterServerUrl'] as String? ?? ''),
      selectedCountry: map['selectedCountry'] as String? ?? 'UAE',
      selectedCity: map['selectedCity'] as String? ?? 'Dubai',
      layoutStyle: const ['classic', 'modern'].contains(map['layoutStyle'])
          ? map['layoutStyle'] as String
          : 'modern',
      adhanSound: const ['default', 'raad_al_kurdi'].contains(map['adhanSound'])
          ? map['adhanSound'] as String
          : 'default',
      isMakkahStreamEnabled: map['isMakkahStreamEnabled'] as bool? ?? false,
      isMakkahStreamAudioEnabled:
          map['isMakkahStreamAudioEnabled'] as bool? ?? false,
    );
  }
}
