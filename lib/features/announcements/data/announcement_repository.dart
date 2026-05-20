import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/announcement.dart';
import '../domain/i_announcement_repository.dart';
import 'datasources/announcement_remote_config_data_source.dart';

class AnnouncementRepository implements IAnnouncementRepository {
  AnnouncementRepository(this._dataSource);

  static const _seenKey = 'announcement_last_seen_id';

  final AnnouncementRemoteConfigDataSource _dataSource;

  @override
  Future<Either<Failure, Announcement?>> fetchActive() async {
    try {
      return Right(_dataSource.read());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<bool> hasSeen(String announcementId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_seenKey) == announcementId;
  }

  @override
  Future<void> markSeen(String announcementId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_seenKey, announcementId);
  }
}
