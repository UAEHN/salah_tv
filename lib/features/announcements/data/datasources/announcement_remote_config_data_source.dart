import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/announcement.dart';

/// Reads the broadcast announcement from Firebase Remote Config.
///
/// Returns `null` when `announcement_active` is false or
/// `announcement_id` is empty — that is the normal "no announcement" state
/// and is not an error. Throws [ServerException] on read failure so the
/// repository can map it.
class AnnouncementRemoteConfigDataSource {
  AnnouncementRemoteConfigDataSource({FirebaseRemoteConfig? rc})
      : _rc = rc ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _rc;

  Announcement? read() {
    try {
      final isActive = _rc.getBool(AppConfig.rcKeyAnnouncementActive);
      final id = _rc.getString(AppConfig.rcKeyAnnouncementId).trim();
      final title = _rc.getString(AppConfig.rcKeyAnnouncementTitleAr);
      final minV = _rc.getInt(AppConfig.rcKeyAnnouncementMinVersionCode);
      final maxV = _rc.getInt(AppConfig.rcKeyAnnouncementMaxVersionCode);

      if (kDebugMode) {
        debugPrint(
          '[AnnouncementRC] active=$isActive id="$id" title="$title" '
          'minV=$minV maxV=$maxV '
          'lastFetchStatus=${_rc.lastFetchStatus}',
        );
      }

      if (!isActive || id.isEmpty) return null;

      return Announcement(
        id: id,
        titleAr: title,
        titleEn: _rc.getString(AppConfig.rcKeyAnnouncementTitleEn),
        bodyAr: _rc.getString(AppConfig.rcKeyAnnouncementBodyAr),
        bodyEn: _rc.getString(AppConfig.rcKeyAnnouncementBodyEn),
        ctaUrl: _rc.getString(AppConfig.rcKeyAnnouncementCtaUrl),
        ctaLabelAr: _rc.getString(AppConfig.rcKeyAnnouncementCtaLabelAr),
        ctaLabelEn: _rc.getString(AppConfig.rcKeyAnnouncementCtaLabelEn),
        minVersionCode: minV,
        maxVersionCode: maxV,
      );
    } catch (e) {
      throw ServerException('Announcement RC read failed: $e');
    }
  }
}
