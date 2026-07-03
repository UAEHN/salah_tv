import 'diagnostic_level.dart';

class DiagnosticEvent {
  DiagnosticEvent({
    required this.level,
    required this.name,
    required this.at,
    this.deviceId,
    this.installationId,
    this.sessionId,
    this.userId,
    this.fields = const {},
  });

  final DiagnosticLevel level;
  final String name;
  final DateTime at;
  final String? deviceId;
  final String? installationId;
  final String? sessionId;
  final String? userId;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {
    'level': level.wireName,
    'name': name,
    'at': at.toIso8601String(),
    if (deviceId != null) 'device_id': deviceId,
    if (installationId != null) 'installation_id': installationId,
    if (sessionId != null) 'session_id': sessionId,
    if (userId != null) 'user_id': userId,
    'fields': fields,
  };
}
