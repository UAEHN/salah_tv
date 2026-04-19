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

  static bool get hasTelegramConfig =>
      telegramBotToken.isNotEmpty && telegramChatId.isNotEmpty;

  static String? get telegramSendUrl {
    if (!hasTelegramConfig) return null;
    return 'https://api.telegram.org/bot$telegramBotToken/sendMessage';
  }
}
