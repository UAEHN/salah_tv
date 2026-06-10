import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/remote_version_info.dart';
import '../entities/update_status.dart';
import '../i_app_version_info_port.dart';
import '../i_remote_version_repository.dart';

/// Compares the installed build number against the remote version metadata
/// and produces an [UpdateDecision]. The caller (UI bridge) decides what
/// dialog — if any — to show.
class CheckForUpdateUseCase {
  CheckForUpdateUseCase({required this.remoteRepo, required this.versionInfo});

  final IRemoteVersionRepository remoteRepo;
  final IAppVersionInfoPort versionInfo;

  Future<Either<Failure, UpdateDecision>> call() async {
    final remote = await remoteRepo.fetchLatest();
    return remote.fold(Left.new, (info) async {
      final current = await versionInfo.currentBuildNumber();
      return Right(
        UpdateDecision(status: _classify(current, info), info: info),
      );
    });
  }

  UpdateStatus _classify(int current, RemoteVersionInfo info) {
    if (current < info.minSupportedVersionCode) return UpdateStatus.forced;
    if (current < info.latestVersionCode) return UpdateStatus.optional;
    return UpdateStatus.upToDate;
  }
}
