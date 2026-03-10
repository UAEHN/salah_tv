import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../../domain/entities/app_version.dart';
import '../../domain/repositories/update_repository.dart';
import '../datasources/update_remote_datasource.dart';

@Injectable(as: UpdateRepository)
class UpdateRepositoryImpl implements UpdateRepository {
  final UpdateRemoteDataSource remoteDataSource;

  UpdateRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AppVersion?>> checkForUpdate() async {
    try {
      final data = await remoteDataSource.fetchLatestVersion();
      final latestVersion = data['version'] as String;
      final apkUrl = data['apk_url'] as String;
      final isMandatory = data['is_mandatory'] as bool? ?? true;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewerVersion(latestVersion, currentVersion)) {
        return Right(
          AppVersion(
            version: latestVersion,
            apkUrl: apkUrl,
            isMandatory: isMandatory,
          ),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> downloadUpdate({
    required String url,
    required Function(int, int) onProgress,
  }) async {
    try {
      final path = await remoteDataSource.downloadApk(url, onProgress);
      return Right(path);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> installUpdate(String filePath) async {
    try {
      await remoteDataSource.installApk(filePath);
      return const Right(Success());
    } catch (e) {
      return Left(CacheFailure('Install failed: $e'));
    }
  }

  bool _isNewerVersion(String latest, String current) {
    try {
      final cleanLatest = latest.replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanCurrent = current.replaceAll(RegExp(r'[^0-9.]'), '');

      final v1 = cleanLatest.split('.').map(int.parse).toList();
      final v2 = cleanCurrent.split('.').map(int.parse).toList();

      for (var i = 0; i < v1.length; i++) {
        if (v1[i] > (v2.length > i ? v2[i] : 0)) return true;
        if (v1[i] < (v2.length > i ? v2[i] : 0)) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
