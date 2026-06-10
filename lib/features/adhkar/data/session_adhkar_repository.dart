import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/entities/adhkar_session.dart';
import '../domain/entities/dhikr.dart';
import '../domain/i_session_adhkar_repository.dart';

const _kMorningCategory = 'أذكار الصباح';
const _kEveningCategory = 'أذكار المساء';

/// Loads the morning/evening adhkar (text + count + audio asset path) from the
/// bundled `assets/audio/adhkar.json`. Display + audio source for the TV
/// session-adhkar takeover; no session-shown tracking (the prayer engine owns
/// when the takeover appears).
class SessionAdhkarRepository implements ISessionAdhkarRepository {
  List<Dhikr> _morning = const [];
  List<Dhikr> _evening = const [];

  Future<void> initialize() async {
    try {
      final raw = await rootBundle.loadString('assets/audio/adhkar.json');
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _morning = list
          .where((e) => e['category'] == _kMorningCategory)
          .map(Dhikr.fromJson)
          .toList();
      _evening = list
          .where((e) => e['category'] == _kEveningCategory)
          .map(Dhikr.fromJson)
          .toList();
      debugPrint(
        '[SessionAdhkar] morning=${_morning.length} evening=${_evening.length}',
      );
    } catch (e) {
      debugPrint('[SessionAdhkar] initialize failed: $e');
    }
  }

  @override
  List<Dhikr> forSession(AdhkarSession session) => switch (session) {
    AdhkarSession.morning => _morning,
    AdhkarSession.evening => _evening,
    AdhkarSession.none => const [],
  };
}
