/// Wire values for [Breadcrumb.type] — must match the dashboard's timeline
/// icon mapping and the Firestore rules whitelist.
class BreadcrumbType {
  const BreadcrumbType._();

  static const String nav = 'nav';
  static const String key = 'key';
  static const String focus = 'focus';
  static const String api = 'api';
  static const String cycle = 'cycle';
  static const String diag = 'diag';
  static const String lifecycle = 'lifecycle';
}

/// One user/system action captured before an error (navigation, D-pad press,
/// focus move, API call, prayer-cycle event…). Stored as a rolling trail of
/// the last ~20 entries on every error record.
class Breadcrumb {
  const Breadcrumb({
    required this.at,
    required this.type,
    required this.name,
    this.data,
  });

  /// Rebuilds a crumb from its [toJson] shape — used to reload the previous
  /// session's trail (breadcrumb_persistence) so a native crash carries it.
  /// Fail-soft: missing/typed-wrong fields degrade to safe defaults.
  factory Breadcrumb.fromJson(Map<String, Object?> json) {
    final rawData = json['data'];
    return Breadcrumb(
      at:
          DateTime.tryParse(json['t'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: json['type'] as String? ?? BreadcrumbType.diag,
      name: json['name'] as String? ?? 'unknown',
      data: rawData is Map
          ? {for (final e in rawData.entries) e.key.toString(): e.value}
          : null,
    );
  }

  final DateTime at;
  final String type;
  final String name;
  final Map<String, Object?>? data;

  Map<String, Object?> toJson() {
    final extra = data;
    return {
      't': at.toIso8601String(),
      'type': type,
      'name': name,
      if (extra != null && extra.isNotEmpty) 'data': extra,
    };
  }
}
