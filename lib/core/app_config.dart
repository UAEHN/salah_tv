/// Central configuration constants.
/// All hardcoded URLs and keys live here — never inline in data sources.
abstract class AppConfig {
  static String quranReciterApiUrl({String language = 'ar'}) =>
      'https://mp3quran.net/api/v3/reciters?language=$language';

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

  static bool get hasTelegramConfig =>
      telegramBotToken.isNotEmpty && telegramChatId.isNotEmpty;

  static String? get telegramSendUrl {
    if (!hasTelegramConfig) return null;
    return 'https://api.telegram.org/bot$telegramBotToken/sendMessage';
  }
}
