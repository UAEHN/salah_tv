import 'package:cloud_firestore/cloud_firestore.dart';

/// Writes one raw error event to Firestore `error_events` (append-only —
/// grouping happens server-side in Cloud Functions). Adds the server
/// timestamp and the TTL field the Firestore TTL policy deletes on.
class FirestoreErrorUploader {
  FirestoreErrorUploader({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'error_events';
  static const Duration _retention = Duration(days: 30);
  static const Duration _timeout = Duration(seconds: 15);

  /// Returns true only when the write is confirmed — the flusher keeps the
  /// row queued otherwise. Uses the record's own `event_id` as document id
  /// so a retry after a timed-out-but-landed write overwrites instead of
  /// duplicating (the SDK's internal offline queue can outlive our timeout).
  Future<bool> upload(Map<String, Object?> payload) async {
    try {
      final clientAt =
          DateTime.tryParse(payload['client_at'] as String? ?? '') ??
          DateTime.now();
      final data = {
        ...payload,
        'created_at': FieldValue.serverTimestamp(),
        'expire_at': Timestamp.fromDate(clientAt.add(_retention)),
      };
      final eventId = payload['event_id'] as String?;
      final docRef = eventId != null && eventId.isNotEmpty
          ? _firestore.collection(_collection).doc(eventId)
          : _firestore.collection(_collection).doc();
      await docRef.set(data).timeout(_timeout);
      return true;
    } catch (_) {
      return false;
    }
  }
}
