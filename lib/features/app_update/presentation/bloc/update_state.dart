import '../../domain/entities/app_version.dart';

abstract class UpdateState {}

class UpdateInitial extends UpdateState {}

class UpdateChecking extends UpdateState {}

class UpdateAvailable extends UpdateState {
  final AppVersion appVersion;
  UpdateAvailable(this.appVersion);
}

class UpdateNotAvailable extends UpdateState {}

class UpdateDownloading extends UpdateState {
  final double progress;
  UpdateDownloading(this.progress);
}

class UpdateInstalling extends UpdateState {}

class UpdateError extends UpdateState {
  final String message;
  UpdateError(this.message);
}
