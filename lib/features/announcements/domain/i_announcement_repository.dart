import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'entities/announcement.dart';

/// Domain contract for the broadcast announcement feature.
///
/// `fetchActive` returns `Right(null)` when Remote Config is disabled or
/// has no announcement to show — that is a normal "nothing to do" outcome,
/// not a failure.
abstract class IAnnouncementRepository {
  Future<Either<Failure, Announcement?>> fetchActive();

  Future<bool> hasSeen(String announcementId);

  Future<void> markSeen(String announcementId);
}
