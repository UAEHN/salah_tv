import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/i_quran_intro_flag_repository.dart';

/// SharedPreferences-backed flag for the Mushaf reader intro sheet.
/// Defaults to "not seen" on any read error so the user still gets the
/// onboarding rather than silently missing it.
class QuranIntroFlagRepository implements IQuranIntroFlagRepository {
  static const _kKey = 'mushaf_intro_seen_v1';

  @override
  Future<bool> hasSeenIntro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kKey) ?? false;
    } catch (e) {
      debugPrint('[QuranIntroFlag] read failed: $e');
      return false;
    }
  }

  @override
  Future<void> markIntroSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kKey, true);
    } catch (e) {
      debugPrint('[QuranIntroFlag] write failed: $e');
    }
  }
}
