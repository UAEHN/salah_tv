import 'dart:convert';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/failures.dart';
import '../../../core/error/push_notification_failure.dart';
import '../domain/i_install_id_provider.dart';

/// Generates a 22-char URL-safe random id on first call and persists it in
/// SharedPreferences. Subsequent calls return the same value.
///
/// Not cryptographically tied to a user — purely a stable doc key so Firestore
/// updates target the same row across token rotations.
class SharedPrefsInstallIdProvider implements IInstallIdProvider {
  static const String _kInstallIdKey = 'push.installId';

  @override
  Future<Either<Failure, String>> getOrCreate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_kInstallIdKey);
      if (existing != null && existing.isNotEmpty) return Right(existing);
      final fresh = _generate();
      await prefs.setString(_kInstallIdKey, fresh);
      return Right(fresh);
    } catch (e) {
      return Left(PushNotificationFailure('install-id getOrCreate: $e'));
    }
  }

  String _generate() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
