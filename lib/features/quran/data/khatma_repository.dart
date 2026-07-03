import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/khatma_plan.dart';
import '../domain/i_khatma_repository.dart';

/// SharedPreferences-backed single-slot Khatma store. Kept outside
/// `AppSettings` because the reading plan is a Quran-feature concern. The plan
/// and its progress are small (≤604 page ids + one int per active day), so a
/// single JSON blob is plenty — no SQLite needed.
class KhatmaRepository implements IKhatmaRepository {
  static const String _key = 'active_khatma';

  @override
  Future<Khatma?> getActiveKhatma() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      return Khatma.fromJson(json);
    } catch (e) {
      debugPrint('[Khatma] read failed: $e');
      return null;
    }
  }

  @override
  Future<void> saveKhatma(Khatma khatma) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(khatma.toJson()));
    } catch (e) {
      debugPrint('[Khatma] write failed: $e');
    }
  }

  @override
  Future<void> clearKhatma() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('[Khatma] clear failed: $e');
    }
  }
}
