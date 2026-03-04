import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  static const _prefix = 'salah_tv_';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings.fromMap({
      'themeColorKey': prefs.getString('${_prefix}theme'),
      'use24HourFormat': prefs.getBool('${_prefix}24h'),
      'playAdhan': prefs.getBool('${_prefix}adhan'),
      'isDarkMode': prefs.getBool('${_prefix}dark_mode'),
      'csvFilePath': prefs.getString('${_prefix}csv_path'),
      'iqamaDelays': prefs.getString('${_prefix}iqama'),
      'adhanOffsets': prefs.getString('${_prefix}adhan_offsets'),
      'hadithText': prefs.getString('${_prefix}hadith_text'),
      'hadithSource': prefs.getString('${_prefix}hadith_source'),
      'fontFamily': prefs.getString('${_prefix}font_family'),
      'isQuranEnabled': prefs.getBool('${_prefix}quran_enabled'),
      'quranReciterName': prefs.getString('${_prefix}quran_reciter_name'),
      'quranReciterServerUrl':
          prefs.getString('${_prefix}quran_reciter_url'),
    });
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix}theme', s.themeColorKey);
    await prefs.setBool('${_prefix}24h', s.use24HourFormat);
    await prefs.setBool('${_prefix}adhan', s.playAdhan);
    await prefs.setBool('${_prefix}dark_mode', s.isDarkMode);
    if (s.csvFilePath != null) {
      await prefs.setString('${_prefix}csv_path', s.csvFilePath!);
    } else {
      await prefs.remove('${_prefix}csv_path');
    }
    await prefs.setString('${_prefix}iqama', jsonEncode(s.iqamaDelays));
    await prefs.setString(
        '${_prefix}adhan_offsets', jsonEncode(s.adhanOffsets));
    await prefs.setString('${_prefix}hadith_text', s.hadithText);
    await prefs.setString('${_prefix}hadith_source', s.hadithSource);
    await prefs.setString('${_prefix}font_family', s.fontFamily);
    await prefs.setBool('${_prefix}quran_enabled', s.isQuranEnabled);
    await prefs.setString(
        '${_prefix}quran_reciter_name', s.quranReciterName);
    await prefs.setString(
        '${_prefix}quran_reciter_url', s.quranReciterServerUrl);
  }
}
