import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys for [AppSettings] persistence. Single source of
/// truth shared by [loadAppSettings] and [saveAppSettings] to keep the
/// round-trip in sync.
const _p = 'salah_tv_';

class PrefsKeys {
  PrefsKeys._();
  static const theme = '${_p}theme';
  static const h24 = '${_p}24h';
  static const adhan = '${_p}adhan'; // legacy bool — kept for migration only
  static const iqama2 = '${_p}iqama_play'; // legacy bool — migration only
  static const adhanMode = '${_p}adhan_mode';
  static const iqamaMode = '${_p}iqama_mode';
  static const mosqueMode = '${_p}mosque_mode';
  static const dark = '${_p}dark_mode';
  static const iqama = '${_p}iqama';
  static const adhanOff = '${_p}adhan_offsets';
  static const hadithText = '${_p}hadith_text';
  static const hadithSrc = '${_p}hadith_source';
  static const font = '${_p}font_family';
  static const locale = '${_p}locale';
  static const quranEnabled = '${_p}quran_enabled';
  static const reciterName = '${_p}quran_reciter_name';
  static const reciterUrl = '${_p}quran_reciter_url';
  static const favReciters = '${_p}favorite_reciters';
  static const country = '${_p}selected_country';
  static const city = '${_p}selected_city';
  static const lat = '${_p}selected_lat';
  static const lng = '${_p}selected_lng';
  static const calcMethod = '${_p}calc_method';
  static const madhab = '${_p}madhab';
  static const isCalc = '${_p}is_calculated_location';
  static const tzId = '${_p}timezone_id';
  static const utcOff = '${_p}utc_offset';
  static const layout = '${_p}layout_style';
  static const adhanSound = '${_p}adhan_sound';
  static const analog = '${_p}analog_clock';
  static const adhkar = '${_p}adhkar_enabled';
  static const prayerNotif = '${_p}prayer_notif_enabled';
  static const preAdhanMap = '${_p}pre_adhan_reminder_map';
  static const preAdhanMin = '${_p}pre_adhan_reminder_min';
  static const iqamaNotif = '${_p}iqama_notif_map';
  static const preIqamaMap = '${_p}pre_iqama_reminder_map';
  static const preIqamaMin = '${_p}pre_iqama_reminder_min';
  static const morningAdhkarNotif = '${_p}morning_adhkar_notif';
  static const eveningAdhkarNotif = '${_p}evening_adhkar_notif';
  static const morningAdhkarMinuteOfDay = '${_p}morning_adhkar_minute';
  static const eveningAdhkarMinuteOfDay = '${_p}evening_adhkar_minute';
  static const notifOnboardingDone = '${_p}notif_onboarding_done';
  static const customAdhans = '${_p}custom_adhans';
  static const playbackMode = '${_p}quran_playback_mode';
  static const selectedSurah = '${_p}quran_selected_surah';
  static const playlist = '${_p}quran_surah_playlist';
  static const repeatCount = '${_p}quran_surah_repeat';
  static const cycleCount = '${_p}quran_playlist_cycle';
  static const continuousStart = '${_p}quran_continuous_start';
  static const lastPlayed = '${_p}quran_last_played';
}

Future<void> setOrRemoveString(
  SharedPreferences prefs,
  String key,
  String? value,
) async {
  if (value != null && value.isNotEmpty) {
    await prefs.setString(key, value);
  } else {
    await prefs.remove(key);
  }
}

Future<void> setOrRemoveDouble(
  SharedPreferences prefs,
  String key,
  double? value,
) async {
  if (value != null) {
    await prefs.setDouble(key, value);
  } else {
    await prefs.remove(key);
  }
}

Future<void> setOrRemoveInt(
  SharedPreferences prefs,
  String key,
  int? value,
) async {
  if (value != null) {
    await prefs.setInt(key, value);
  } else {
    await prefs.remove(key);
  }
}
