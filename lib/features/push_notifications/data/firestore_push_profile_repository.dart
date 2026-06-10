import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/error/push_notification_failure.dart';
import '../domain/entities/push_profile.dart';
import '../domain/i_push_profile_repository.dart';

/// Writes the device profile to `push_profiles/{installId}` via `set(merge)`
/// so repeated boot-time syncs do not overwrite server-side fields a future
/// Cloud Function might add (e.g. derived segments, last-seen counters).
class FirestorePushProfileRepository implements IPushProfileRepository {
  static const String _collection = 'push_profiles';

  final FirebaseFirestore _firestore;

  FirestorePushProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, Unit>> save(PushProfile profile) async {
    try {
      final doc = _firestore.collection(_collection).doc(profile.installId);
      final data = <String, dynamic>{
        'fcmToken': profile.fcmToken,
        'language': profile.language,
        'country': profile.country,
        if (profile.city != null) 'city': profile.city,
        'timezone': profile.timezone,
        'platform': profile.platform,
        'appVersion': profile.appVersion,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await doc.set(data, SetOptions(merge: true));
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(PushNotificationFailure('firestore save: ${e.message}'));
    } catch (e) {
      return Left(PushNotificationFailure('firestore save: $e'));
    }
  }
}
