import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/check_update_usecase.dart';
import '../../domain/usecases/download_install_usecase.dart';
import 'update_event.dart';
import 'update_state.dart';

@injectable
class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final CheckUpdateUseCase checkUpdate;
  final DownloadInstallUseCase downloadInstall;

  UpdateBloc(this.checkUpdate, this.downloadInstall)
      : super(UpdateInitial()) {
    on<CheckForUpdateEvent>(_onCheckForUpdate);
    on<StartDownloadEvent>(_onStartDownload);
    on<UpdateProgressEvent>(_onUpdateProgress);
  }

  Future<void> _onCheckForUpdate(
    CheckForUpdateEvent event,
    Emitter<UpdateState> emit,
  ) async {
    emit(UpdateChecking());
    final result = await checkUpdate();
    result.fold(
      (failure) => emit(UpdateError(failure.message)),
      (appVersion) {
        if (appVersion != null) {
          emit(UpdateAvailable(appVersion));
        } else {
          emit(UpdateNotAvailable());
        }
      },
    );
  }

  Future<void> _onStartDownload(
    StartDownloadEvent event,
    Emitter<UpdateState> emit,
  ) async {
    emit(UpdateDownloading(0.0));
    final result = await downloadInstall(
      url: event.apkUrl,
      onProgress: (received, total) {
        if (total != -1 && !isClosed) {
          add(UpdateProgressEvent(received, total));
        }
      },
    );

    result.fold(
      (failure) => emit(UpdateError(failure.message)),
      (_) => emit(UpdateInstalling()),
    );
  }

  void _onUpdateProgress(
    UpdateProgressEvent event,
    Emitter<UpdateState> emit,
  ) {
    emit(UpdateDownloading(event.receivedBytes / event.totalBytes));
  }
}
