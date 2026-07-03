/// Status of a Khatma (Quran completion plan).
enum KhatmaStatus { active, completed }

/// A single active Khatma — a plan to read a page range of the Mushaf within
/// a target date, plus the running progress.
///
/// Persisted as one JSON blob via `IKhatmaRepository`. Only one Khatma is
/// active at a time (single-slot, like the bookmark) — a product decision
/// matching how mainstream Quran apps surface a single reading goal.
///
/// Progress is page-based (1–604 Madani Mushaf): [readPages] holds the
/// distinct pages completed (bounded by the range, ≤604) and [dailyLog] maps
/// a 'yyyy-MM-dd' day key to the count of NEW pages read that calendar day
/// (bounded by the plan duration). Both collections are naturally bounded, so
/// no eviction rule is needed. Re-reading a page does not advance the Khatma.
class Khatma {
  final int startPage;
  final int endPage;
  final DateTime startDate; // date-only
  final DateTime targetDate; // date-only
  final DateTime createdAt;
  final KhatmaStatus status;
  final Set<int> readPages;
  final Map<String, int> dailyLog;

  Khatma({
    required this.startPage,
    required this.endPage,
    required this.startDate,
    required this.targetDate,
    required this.createdAt,
    this.status = KhatmaStatus.active,
    Set<int> readPages = const {},
    Map<String, int> dailyLog = const {},
  }) : readPages = Set.unmodifiable(readPages),
       dailyLog = Map.unmodifiable(dailyLog);

  int get totalPages => endPage - startPage + 1;
  int get readCount => readPages.length;
  bool get isCompleted => readCount >= totalPages;

  Khatma copyWith({
    KhatmaStatus? status,
    Set<int>? readPages,
    Map<String, int>? dailyLog,
  }) {
    return Khatma(
      startPage: startPage,
      endPage: endPage,
      startDate: startDate,
      targetDate: targetDate,
      createdAt: createdAt,
      status: status ?? this.status,
      readPages: readPages ?? this.readPages,
      dailyLog: dailyLog ?? this.dailyLog,
    );
  }

  Map<String, dynamic> toJson() => {
    'startPage': startPage,
    'endPage': endPage,
    'startDate': startDate.toIso8601String(),
    'targetDate': targetDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'readPages': readPages.toList(),
    'dailyLog': dailyLog,
  };

  static Khatma? fromJson(Map<String, dynamic> json) {
    final startPage = json['startPage'];
    final endPage = json['endPage'];
    if (startPage is! int || endPage is! int) return null;
    final start = DateTime.tryParse(json['startDate'] as String? ?? '');
    final target = DateTime.tryParse(json['targetDate'] as String? ?? '');
    final created = DateTime.tryParse(json['createdAt'] as String? ?? '');
    if (start == null || target == null || created == null) return null;

    final pages = (json['readPages'] as List?)?.whereType<int>().toSet() ?? {};
    final log = <String, int>{};
    final rawLog = json['dailyLog'];
    if (rawLog is Map) {
      rawLog.forEach((k, v) {
        if (k is String && v is int) log[k] = v;
      });
    }

    return Khatma(
      startPage: startPage,
      endPage: endPage,
      startDate: start,
      targetDate: target,
      createdAt: created,
      status: KhatmaStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => KhatmaStatus.active,
      ),
      readPages: pages,
      dailyLog: log,
    );
  }
}
