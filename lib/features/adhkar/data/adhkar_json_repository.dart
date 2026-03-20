import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/adhkar_session.dart';
import '../domain/entities/dhikr.dart';
import '../domain/i_adhkar_state_repository.dart';

const _kMorningShownKey = 'adhkar_morning_shown_date';
const _kEveningShownKey = 'adhkar_evening_shown_date';

/// Loads adhkar content from [assets/audio/adhkar.json] once at startup.
/// Also implements [IAdhkarStateRepository] for once-per-day session tracking.
class AdhkarJsonRepository implements IAdhkarStateRepository {
  List<Dhikr> _morning = const [];
  List<Dhikr> _evening = const [];
  SharedPreferences? _prefs;
  bool _isMorningSessionActive = false;
  bool _isEveningSessionActive = false;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = await rootBundle.loadString('assets/audio/adhkar.json');
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _morning = list
          .where((e) => e['category'] == 'أذكار الصباح')
          .map((e) => Dhikr.fromJson(e))
          .toList();
      _evening = list
          .where((e) => e['category'] == 'أذكار المساء')
          .map((e) => Dhikr.fromJson(e))
          .toList();
      debugPrint('[AdhkarRepo] morning=${_morning.length} evening=${_evening.length}');
    } catch (e) {
      debugPrint('[AdhkarRepo] initialize failed: $e');
    }
  }

  @override
  List<Dhikr> forSession(AdhkarSession session) {
    switch (session) {
      case AdhkarSession.morning:
        return _morning;
      case AdhkarSession.evening:
        // TODO: replace with real evening data when available
        return _evening.isNotEmpty ? _evening : _morning;
      case AdhkarSession.none:
        return const [];
    }
  }

  // ── IAdhkarStateRepository ────────────────────────────────────────────────

  @override
  bool get isMorningSessionActive => _isMorningSessionActive;

  @override
  bool hasMorningAdhkarShownToday() {
    final stored = _prefs?.getString(_kMorningShownKey);
    if (stored == null) return false;
    final today = _todayString();
    return stored == today;
  }

  @override
  Future<void> startMorningSession() async {
    _isMorningSessionActive = true;
    await _prefs?.setString(_kMorningShownKey, _todayString());
  }

  @override
  void endMorningSession() => _isMorningSessionActive = false;

  // ── Evening session ───────────────────────────────────────────────────────

  @override
  bool get isEveningSessionActive => _isEveningSessionActive;

  @override
  bool hasEveningAdhkarShownToday() {
    final stored = _prefs?.getString(_kEveningShownKey);
    if (stored == null) return false;
    return stored == _todayString();
  }

  @override
  Future<void> startEveningSession() async {
    _isEveningSessionActive = true;
    await _prefs?.setString(_kEveningShownKey, _todayString());
  }

  @override
  void endEveningSession() => _isEveningSessionActive = false;

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
