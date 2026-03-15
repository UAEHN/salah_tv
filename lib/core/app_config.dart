/// Central configuration constants.
/// All hardcoded URLs and keys live here — never inline in data sources.
abstract class AppConfig {
  static const String quranReciterApiUrl =
      'https://mp3quran.net/api/v3/reciters?language=ar';

  static const String appVersionCheckUrl =
      'https://gist.githubusercontent.com/UAEHN/'
      '0f3dbd6d07c1217e97e414e777a28bd4/raw/app_version.json';

  static const String makkahLiveStreamUrl =
      'https://live.kwikmotion.com/sharjahtvquranlive/shqurantv.smil/playlist.m3u8';
}
