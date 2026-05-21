import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/quran_bookmark.dart';
import '../domain/i_quran_bookmark_repository.dart';

/// SharedPreferences-backed single-slot bookmark store. Kept outside
/// `AppSettings` because bookmarks are a Quran-feature concern and don't
/// belong in the global settings codec.
class QuranBookmarkRepository implements IQuranBookmarkRepository {
  static const String _key = 'quran_bookmark';

  @override
  Future<QuranBookmark?> getBookmark() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      return QuranBookmark.fromJson(json);
    } catch (e) {
      debugPrint('[QuranBookmark] read failed: $e');
      return null;
    }
  }

  @override
  Future<void> saveBookmark(QuranBookmark bookmark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(bookmark.toJson()));
    } catch (e) {
      debugPrint('[QuranBookmark] write failed: $e');
    }
  }
}
