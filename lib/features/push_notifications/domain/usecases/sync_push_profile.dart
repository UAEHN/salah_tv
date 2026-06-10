import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/push_profile.dart';
import '../i_install_id_provider.dart';
import '../i_push_notifications_repository.dart';
import '../i_push_profile_repository.dart';

/// Composes the install id, the current FCM token, and the device profile
/// fields supplied by the caller, then writes the row to Firestore.
///
/// Idempotent — safe to call on every boot and on every onTokenRefresh.
/// Returns `Right(null)` (no-op) when permission isn't granted yet or the
/// token cannot be obtained, so callers don't need to gate the call.
class SyncPushProfile {
  final IInstallIdProvider installIdProvider;
  final IPushNotificationsRepository pushRepo;
  final IPushProfileRepository profileRepo;

  const SyncPushProfile({
    required this.installIdProvider,
    required this.pushRepo,
    required this.profileRepo,
  });

  Future<Either<Failure, Unit>> call({
    required String language,
    required String country,
    required String timezone,
    required String platform,
    required String appVersion,
    String? city,
    String? overrideToken,
  }) async {
    final idEither = await installIdProvider.getOrCreate();
    final installId = idEither.fold((_) => null, (id) => id);
    if (installId == null) return const Right(unit);

    String? token = overrideToken;
    if (token == null) {
      final tokenEither = await pushRepo.getToken();
      token = tokenEither.fold((_) => null, (t) => t);
    }
    if (token == null || token.isEmpty) return const Right(unit);

    final profile = PushProfile(
      installId: installId,
      fcmToken: token,
      language: language,
      country: country,
      city: city,
      timezone: timezone,
      platform: platform,
      appVersion: appVersion,
    );
    return profileRepo.save(profile);
  }
}
