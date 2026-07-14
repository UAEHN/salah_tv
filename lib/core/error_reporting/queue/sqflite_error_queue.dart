import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// One queued error event. [payload] is null when the stored JSON is corrupt
/// — the flusher deletes such rows without uploading.
class QueuedError {
  const QueuedError({required this.id, required this.payload});

  final int id;
  final Map<String, Object?>? payload;
}

/// Durable FIFO queue over `error_queue.db`. Survives process death and
/// offline periods; bounded at [_maxRows] rows with drop-oldest eviction
/// (§9 CLAUDE.md — no unbounded growth on a 24/7 TV).
class SqfliteErrorQueue {
  SqfliteErrorQueue(this._db, {int maxRows = 500}) : _maxRows = maxRows;

  final Database _db;
  final int _maxRows;
  static const _table = 'error_queue';

  /// Returns false on any storage failure — the caller treats the event as
  /// dropped (reporting must never throw).
  Future<bool> enqueue(Map<String, Object?> payload) async {
    try {
      await _db.transaction((txn) async {
        await txn.insert(_table, {
          'payload': jsonEncode(payload),
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
        // Cap enforcement in the same transaction: keep the newest rows.
        await txn.rawDelete(
          'DELETE FROM $_table WHERE id NOT IN '
          '(SELECT id FROM $_table ORDER BY id DESC LIMIT ?)',
          [_maxRows],
        );
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<QueuedError>> peekOldest(int limit) async {
    try {
      final rows = await _db.query(_table, orderBy: 'id ASC', limit: limit);
      return [
        for (final row in rows)
          QueuedError(
            id: (row['id'] as int?) ?? -1,
            payload: _decode(row['payload']),
          ),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> delete(List<int> ids) async {
    if (ids.isEmpty) return;
    try {
      final placeholders = List.filled(ids.length, '?').join(',');
      await _db.delete(_table, where: 'id IN ($placeholders)', whereArgs: ids);
    } catch (_) {}
  }

  Future<int> count() async {
    try {
      final result = await _db.rawQuery('SELECT COUNT(*) AS c FROM $_table');
      return (result.first['c'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Map<String, Object?>? _decode(Object? raw) {
    try {
      final decoded = jsonDecode(raw as String);
      return decoded is Map<String, dynamic>
          ? Map<String, Object?>.from(decoded)
          : null;
    } catch (_) {
      return null;
    }
  }
}
