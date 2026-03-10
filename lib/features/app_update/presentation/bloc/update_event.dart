abstract class UpdateEvent {}

class CheckForUpdateEvent extends UpdateEvent {}

class StartDownloadEvent extends UpdateEvent {
  final String apkUrl;
  StartDownloadEvent(this.apkUrl);
}

class UpdateProgressEvent extends UpdateEvent {
  final int receivedBytes;
  final int totalBytes;
  UpdateProgressEvent(this.receivedBytes, this.totalBytes);
}
