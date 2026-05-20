import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import '../domain/entities/app_settings.dart';
import '../domain/i_settings_repository.dart';
import 'settings_prefs_codec.dart';

class SettingsRepository implements ISettingsRepository {
  static const _firstLaunchKey = 'salah_tv_first_launch';
  static const _splashSeenKey = 'salah_tv_splash_seen';

  @override
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  @override
  Future<void> markLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  @override
  Future<bool> hasSeenSplash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_splashSeenKey) ?? false;
  }

  @override
  Future<void> markSplashSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_splashSeenKey, true);
  }

  @override
  Future<Either<Failure, AppSettings>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Right(loadAppSettings(prefs));
    } catch (e) {
      return Left(CacheFailure('Failed to load settings: $e'));
    }
  }

  @override
  Future<Either<Failure, Success>> save(AppSettings s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await saveAppSettings(prefs, s);
      return const Right(Success());
    } catch (e) {
      return Left(CacheFailure('Failed to save settings: $e'));
    }
  }
}
