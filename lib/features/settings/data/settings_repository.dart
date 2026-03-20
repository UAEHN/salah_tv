import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/app_settings_mapper.dart';
import '../domain/i_settings_repository.dart';

class SettingsRepository implements ISettingsRepository {
  static const _prefix = 'salah_tv_';

  @override
  Future<Either<Failure, AppSettings>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Right(
        appSettingsFromMap({
          'themeColorKey': prefs.getString('${_prefix}theme'),
          'use24HourFormat': prefs.getBool('${_prefix}24h'),
          'playAdhan': prefs.getBool('${_prefix}adhan'),
          'isDarkMode': prefs.getBool('${_prefix}dark_mode'),
          'iqamaDelays': prefs.getString('${_prefix}iqama'),
          'adhanOffsets': prefs.getString('${_prefix}adhan_offsets'),
          'hadithText': prefs.getString('${_prefix}hadith_text'),
          'hadithSource': prefs.getString('${_prefix}hadith_source'),
          'fontFamily': prefs.getString('${_prefix}font_family'),
          'isQuranEnabled': prefs.getBool('${_prefix}quran_enabled'),
          'quranReciterName': prefs.getString('${_prefix}quran_reciter_name'),
          'quranReciterServerUrl': prefs.getString('${_prefix}quran_reciter_url'),
          'selectedCountry': prefs.getString('${_prefix}selected_country'),
          'selectedCity': prefs.getString('${_prefix}selected_city'),
          'layoutStyle': prefs.getString('${_prefix}layout_style'),
          'adhanSound': prefs.getString('${_prefix}adhan_sound'),
          'isAnalogClock': prefs.getBool('${_prefix}analog_clock'),
          'isAdhkarEnabled': prefs.getBool('${_prefix}adhkar_enabled'),
        }),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to load settings: $e'));
    }
  }

  @override
  Future<Either<Failure, Success>> save(AppSettings s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_prefix}theme', s.themeColorKey);
      await prefs.setBool('${_prefix}24h', s.use24HourFormat);
      await prefs.setBool('${_prefix}adhan', s.playAdhan);
      await prefs.setBool('${_prefix}dark_mode', s.isDarkMode);
      await prefs.setString('${_prefix}iqama', jsonEncode(s.iqamaDelays));
      await prefs.setString(
        '${_prefix}adhan_offsets',
        jsonEncode(s.adhanOffsets),
      );
      await prefs.setString('${_prefix}hadith_text', s.hadithText);
      await prefs.setString('${_prefix}hadith_source', s.hadithSource);
      await prefs.setString('${_prefix}font_family', s.fontFamily);
      await prefs.setBool('${_prefix}quran_enabled', s.isQuranEnabled);
      await prefs.setString('${_prefix}quran_reciter_name', s.quranReciterName);
      await prefs.setString(
        '${_prefix}quran_reciter_url',
        s.quranReciterServerUrl,
      );
      await prefs.setString('${_prefix}selected_country', s.selectedCountry);
      await prefs.setString('${_prefix}selected_city', s.selectedCity);
      await prefs.setString('${_prefix}layout_style', s.layoutStyle);
      await prefs.setString('${_prefix}adhan_sound', s.adhanSound);
      await prefs.setBool('${_prefix}analog_clock', s.isAnalogClock);
      await prefs.setBool('${_prefix}adhkar_enabled', s.isAdhkarEnabled);
      return const Right(Success());
    } catch (e) {
      return Left(CacheFailure('Failed to save settings: $e'));
    }
  }
}
