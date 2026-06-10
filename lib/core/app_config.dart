/// Central configuration constants.
/// All hardcoded URLs and keys live here — never inline in data sources.
abstract class AppConfig {
  static String quranReciterApiUrl({String language = 'ar'}) =>
      'https://mp3quran.net/api/v3/reciters?language=$language';

  static const String privacyPolicyUrl = 'https://uaehn.github.io/salah_tv/';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.ghasaq.app';

  static const String playStoreMarketUrl = 'market://details?id=com.ghasaq.app';

  /// URL shown as QR code on TV for sending feedback (Telegram group / form).
  /// Replace with the actual link before publishing.
  static const String tvFeedbackUrl = 'https://forms.gle/RVru9wfxZSaV8xfQ9';

  /// Direct support email shown on the mobile feedback page. Empty → tile hidden.
  static const String supportEmail = 'mawaqittvapp@gmail.com';

  /// Direct support Telegram link (e.g. https://t.me/your_handle).
  /// Empty → tile hidden.
  static const String supportTelegramUrl = 'https://t.me/Hassan_hn1';

  /// Display label shown next to the Telegram icon (e.g. "@your_handle").
  /// Falls back to "Telegram" when empty.
  static const String supportTelegramHandle = '@@Hassan_hn1';

  static const String appVersionCheckUrl =
      'https://gist.githubusercontent.com/UAEHN/'
      '0f3dbd6d07c1217e97e414e777a28bd4/raw/app_version.json';

  static const String telegramBotToken = String.fromEnvironment(
    'TELEGRAM_BOT_TOKEN',
    defaultValue: '',
  );

  static const String telegramChatId = String.fromEnvironment(
    'TELEGRAM_CHAT_ID',
    defaultValue: '',
  );

  /// Current app version — must match pubspec.yaml version name.
  /// Update this on every release alongside the Gist JSON.
  static const String kCurrentAppVersion = '0.9.9';

  // ─── Firebase Remote Config — version gating ───────────────────────────────
  /// Latest published versionCode (build number). Clients < this see optional
  /// update; clients < [rcKeyMinSupported] see forced update.
  static const String rcKeyLatestCode = 'app_latest_version_code';
  static const String rcKeyMinSupported = 'app_min_supported_version_code';
  static const String rcKeyStoreUrl = 'app_store_url';
  static const String rcKeyMessageAr = 'app_update_message_ar';

  /// How long a fetched RC value stays valid before re-fetching.
  /// Short on TV — devices stay on for days, we want updates to land same-day.
  static const Duration rcMinFetchInterval = Duration(hours: 1);

  /// Hard cap on RC fetch duration so a flaky network can't block app boot.
  static const Duration rcFetchTimeout = Duration(seconds: 5);

  // ─── Firebase Remote Config — broadcast announcements ──────────────────────
  /// Bumping `announcement_id` is what triggers the dialog for every user
  /// who hasn't yet seen *that* id. Empty string = no announcement.
  static const String rcKeyAnnouncementId = 'announcement_id';
  static const String rcKeyAnnouncementActive = 'announcement_active';
  static const String rcKeyAnnouncementTitleAr = 'announcement_title_ar';
  static const String rcKeyAnnouncementTitleEn = 'announcement_title_en';
  static const String rcKeyAnnouncementBodyAr = 'announcement_body_ar';
  static const String rcKeyAnnouncementBodyEn = 'announcement_body_en';
  static const String rcKeyAnnouncementCtaUrl = 'announcement_cta_url';
  static const String rcKeyAnnouncementCtaLabelAr = 'announcement_cta_label_ar';
  static const String rcKeyAnnouncementCtaLabelEn = 'announcement_cta_label_en';

  /// Targeting by installed `versionCode`. Both 0 → show to everyone.
  /// `min > 0` → only builds at-or-above this build see it.
  /// `max > 0` → only builds at-or-below this build see it.
  static const String rcKeyAnnouncementMinVersionCode =
      'announcement_min_version_code';
  static const String rcKeyAnnouncementMaxVersionCode =
      'announcement_max_version_code';

  // ─── Firebase Remote Config — Eid Takbeerat ────────────────────────────────
  /// Master kill switch. `false` → feature is fully hidden everywhere, no
  /// auto-play, no settings entry, regardless of any other key. Default is
  /// `false` so the feature stays dark until enabled remotely.
  static const String rcKeyTakbeeratEnabled = 'takbeerat_feature_enabled';

  /// Emergency hide — keeps the feature wired but suppresses the home card
  /// and auto-play. Use when a bad audio asset is detected mid-season.
  static const String rcKeyTakbeeratForceHide = 'takbeerat_force_hide';

  /// Force the home card visible regardless of the Hijri calculation. Used
  /// when the local sighting differs from the algorithmic Hijri date.
  static const String rcKeyTakbeeratForceShow = 'takbeerat_force_show';

  /// Day offsets that widen/narrow the "Eid season" window around the
  /// canonical dates (1 Shawwal / 10 Dhul-Hijjah). Stored as ints, never null.
  static const String rcKeyTakbeeratFitrStartOffset =
      'takbeerat_fitr_start_offset_days';
  static const String rcKeyTakbeeratFitrEndOffset =
      'takbeerat_fitr_end_offset_days';
  static const String rcKeyTakbeeratAdhaStartOffset =
      'takbeerat_adha_start_offset_days';
  static const String rcKeyTakbeeratAdhaEndOffset =
      'takbeerat_adha_end_offset_days';

  /// JSON array of reciters: `[{"id":"...","name":"...","url":"..."}]`.
  /// Empty array → feature has no playable content even if enabled.
  static const String rcKeyTakbeeratRecitersJson = 'takbeerat_reciters_json';

  // ─── Nominatim (OpenStreetMap) — global city search ────────────────────────
  /// Free, key-less geocoding for any place worldwide. Solves the «my city
  /// isn't in the bundled catalog» churn problem (especially for European
  /// users). Bundled `world_cities.json` results are preferred when present;
  /// Nominatim is the worldwide fallback.
  static const String nominatimSearchUrl =
      'https://nominatim.openstreetmap.org/search';

  /// Reverse-geocoding endpoint (lat/lng → place). Used by GPS auto-detect
  /// to translate coordinates into a city name, giving the same Nominatim
  /// quality as manual search instead of the native geocoder which often
  /// returns nothing for small towns.
  static const String nominatimReverseUrl =
      'https://nominatim.openstreetmap.org/reverse';

  /// Required by Nominatim usage policy — identifies the app and reachable
  /// contact. Must be a stable, app-specific value (not a browser UA).
  static const String nominatimUserAgent =
      'salah_tv/1.0 (boodeuae0909@gmail.com)';

  static const _prayerDataBase = 'https://uaehn.github.io/salah_tv/prayer_data';

  /// Base URL for dynamic content (occasions manifest, future banners…).
  /// Same GitHub-Pages bucket as prayer data but a different folder so the
  /// publish pipelines stay independent.
  static const _dynamicContentBase = 'https://uaehn.github.io/salah_tv';

  static String prayerCityUrl(String country, String slug) =>
      '$_prayerDataBase/$country/$slug.json';

  static String prayerManifestUrl() => '$_prayerDataBase/manifest.json';

  /// Remote catalog of Hijri occasions (id, hijri date, localized labels,
  /// optional icon/banner/CTA, version targeting). Replaces the bundled
  /// catalog as the source of truth so new occasions can be added without
  /// shipping an APK. App falls back to cache → bundled asset on failure.
  static String occasionsManifestUrl() =>
      '$_dynamicContentBase/occasions/manifest.json';

  /// Per-ayah recitation audio (everyayah.com). `reciterUrlSegment` is
  /// the folder name on the CDN (e.g. `Husary_Muallim_128kbps`).
  /// URL pattern: SSSAAA.mp3 with zero-padded surah and ayah.
  /// Example: surah 1, ayah 1 → 001001.mp3.
  static String ayahAudioUrl({
    required int surah,
    required int ayah,
    required String reciterUrlSegment,
  }) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return 'https://www.everyayah.com/data/$reciterUrlSegment/$s$a.mp3';
  }

  static bool get hasTelegramConfig =>
      telegramBotToken.isNotEmpty && telegramChatId.isNotEmpty;

  static String? get telegramSendUrl {
    if (!hasTelegramConfig) return null;
    return 'https://api.telegram.org/bot$telegramBotToken/sendMessage';
  }
}
