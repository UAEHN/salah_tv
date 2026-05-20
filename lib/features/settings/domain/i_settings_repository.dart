import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import 'entities/app_settings.dart';

abstract class ISettingsRepository {
  Future<Either<Failure, AppSettings>> load();
  Future<Either<Failure, Success>> save(AppSettings settings);
  Future<bool> isFirstLaunch();
  Future<void> markLaunched();

  /// True after the user has seen the full-length splash at least once.
  /// Used to short-circuit the animation on subsequent app launches.
  Future<bool> hasSeenSplash();
  Future<void> markSplashSeen();
}
