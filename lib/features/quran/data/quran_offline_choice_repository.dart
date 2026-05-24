import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/i_quran_offline_choice_repository.dart';

/// SharedPreferences-backed flag for the Mushaf offline-mode prompt.
/// Defaults to "not chosen" on any read error so the user still gets
/// the prompt rather than silently missing it.
class QuranOfflineChoiceRepository implements IQuranOfflineChoiceRepository {
  static const _kKey = 'mushaf_offline_mode_chosen_v1';

  @override
  Future<bool> hasChosenOfflineMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kKey) ?? false;
    } catch (e) {
      debugPrint('[QuranOfflineChoice] read failed: $e');
      return false;
    }
  }

  @override
  Future<void> markChosen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kKey, true);
    } catch (e) {
      debugPrint('[QuranOfflineChoice] write failed: $e');
    }
  }
}
