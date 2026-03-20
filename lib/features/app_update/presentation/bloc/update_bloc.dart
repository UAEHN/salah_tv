import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/app_version.dart';
import '../../domain/usecases/check_update_usecase.dart';
import '../../domain/usecases/download_install_usecase.dart';
import 'update_event.dart';
import 'update_state.dart';

@injectable
class UpdateBloc extends Bloc<UpdateEvent, UpdateState>
    with WidgetsBindingObserver {
  final CheckUpdateUseCase checkUpdate;
  final DownloadInstallUseCase downloadInstall;

  /// Set when installApk fires the Android intent. Consumed on next app resume
  /// so UpdateAvailable is restored only after the user returns from the
  /// native installer — not immediately when the intent is launched.
  AppVersion? _pendingRestore;

  UpdateBloc(this.checkUpdate, this.downloadInstall)
      : super(UpdateInitial()) {
    WidgetsBinding.instance.addObserver(this);
    on<CheckForUpdateEvent>(_onCheckForUpdate);
    on<StartDownloadEvent>(_onStartDownload);
    on<UpdateProgressEvent>(_onUpdateProgress);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed &&
        state is UpdateInstalling &&
        _pendingRestore != null) {
      emit(UpdateAvailable(_pendingRestore!));
      _pendingRestore = null;
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
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
    // Save appVersion before emitting new states so we can restore it on retry.
    final savedVersion = state is UpdateAvailable
        ? (state as UpdateAvailable).appVersion
        : null;

    emit(UpdateDownloading(0.0));
    final result = await downloadInstall(
      url: event.apkUrl,
      onProgress: (received, total) {
        if (total != -1 && !isClosed) {
          add(UpdateProgressEvent(received, total));
        }
      },
      // Emit installing state before the native install intent is launched
      // so the user sees feedback immediately.
      onBeforeInstall: () => emit(UpdateInstalling()),
    );

    result.fold(
      (failure) => emit(UpdateError(failure.message)),
      (_) {
        // installApk returns as soon as the Android intent is fired — NOT when
        // installation completes or is cancelled. Restoring UpdateAvailable here
        // would revert the dialog content while the native installer is still
        // on screen (making the notification appear to "reappear").
        // Store the version and let didChangeAppLifecycleState emit it on resume.
        _pendingRestore = savedVersion;
      },
    );
  }

  void _onUpdateProgress(
    UpdateProgressEvent event,
    Emitter<UpdateState> emit,
  ) {
    emit(UpdateDownloading(event.receivedBytes / event.totalBytes));
  }
}
