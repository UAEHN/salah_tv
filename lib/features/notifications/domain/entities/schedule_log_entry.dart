/// One row of the native engine's schedule log. Built from the JSON the
/// `getHealth` MethodChannel call returns under the `scheduleLog` key.
class ScheduleLogEntry {
  final int id;
  final String type;
  final String? prayerKey;
  final DateTime scheduledFor;
  final DateTime firedAt;
  final bool success;
  final String? error;

  const ScheduleLogEntry({
    required this.id,
    required this.type,
    required this.prayerKey,
    required this.scheduledFor,
    required this.firedAt,
    required this.success,
    required this.error,
  });

  factory ScheduleLogEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleLogEntry(
      id: json['id'] as int,
      type: json['type'] as String,
      prayerKey: _nullable(json['prayerKey']),
      scheduledFor:
          DateTime.fromMillisecondsSinceEpoch(json['scheduledFor'] as int),
      firedAt: DateTime.fromMillisecondsSinceEpoch(json['firedAt'] as int),
      success: json['success'] as bool,
      error: _nullable(json['error']),
    );
  }

  static String? _nullable(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return (s.isEmpty || s == 'null') ? null : s;
  }
}
