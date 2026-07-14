import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import '../../domain/usecases/delete_custom_adhan_usecase.dart';
import '../../domain/usecases/import_custom_adhan_usecase.dart';
import '../settings_provider.dart';

sealed class CustomAdhanState {
  const CustomAdhanState();
}

class CustomAdhanIdle extends CustomAdhanState {
  const CustomAdhanIdle();
}

class CustomAdhanBusy extends CustomAdhanState {
  const CustomAdhanBusy();
}

class CustomAdhanError extends CustomAdhanState {
  final String message;
  const CustomAdhanError(this.message);
}

/// Mediates between the mobile adhan picker UI and the domain use-cases.
/// Holds a reference to [SettingsProvider] (passed at widget layer via
/// [BlocProvider]) so it can persist the metadata list after a successful
/// file-system import/delete.
class CustomAdhanCubit extends Cubit<CustomAdhanState> {
  final ImportCustomAdhanUseCase _import;
  final DeleteCustomAdhanUseCase _delete;
  final SettingsProvider _settings;

  CustomAdhanCubit({
    required ImportCustomAdhanUseCase import,
    required DeleteCustomAdhanUseCase delete,
    required SettingsProvider settings,
  }) : _import = import,
       _delete = delete,
       _settings = settings,
       super(const CustomAdhanIdle());

  /// Mobile picker import. [isIqama] routes the imported sound to the iqama
  /// list instead of the adhan one; selection stays the user's next step.
  Future<void> pickAndImport(String label, {bool isIqama = false}) async {
    emit(const CustomAdhanBusy());
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
      withData: false,
    );
    final file = picked?.files.singleOrNull;
    final path = file?.path;
    if (path == null) {
      emit(const CustomAdhanIdle());
      return;
    }
    final trimmed = label.trim();
    final finalLabel = trimmed.isNotEmpty ? trimmed : _deriveLabel(file!.name);
    final result = await _import(path, finalLabel);
    result.fold((failure) => emit(CustomAdhanError(failure.message)), (
      custom,
    ) async {
      if (isIqama) {
        await _settings.addCustomIqama(custom);
      } else {
        await _settings.addCustomAdhan(custom);
      }
      emit(const CustomAdhanIdle());
    });
  }

  /// TV path: import an audio file the user picked via the D-pad browser
  /// (no [FilePicker]). [isIqama] routes the result to the iqama list/selection
  /// instead of the adhan one. The new sound is auto-selected so the user hears
  /// it on the next cycle without a second step.
  ///
  /// [displayName] is the file's original name as shown in the browser; the
  /// label is derived from it. Falls back to the temp path's basename only if
  /// no display name was provided — the temp file is prefixed `import_<ts>_`
  /// and strips non-ASCII (Arabic) chars, so it must never drive the label.
  Future<void> importFromDevicePath(
    String path, {
    required bool isIqama,
    String? displayName,
  }) async {
    emit(const CustomAdhanBusy());
    final label = _deriveLabel(
      (displayName != null && displayName.trim().isNotEmpty)
          ? displayName
          : p.basename(path),
    );
    final result = await _import(path, label);
    result.fold((failure) => emit(CustomAdhanError(failure.message)), (
      custom,
    ) async {
      if (isIqama) {
        await _settings.addCustomIqama(custom);
        await _settings.updateIqamaSound(custom.settingsKey);
      } else {
        await _settings.addCustomAdhan(custom);
        await _settings.updateAdhanSound(custom.settingsKey);
      }
      emit(const CustomAdhanIdle());
    });
  }

  /// Category-aware delete used by the TV picker for both adhan and iqama.
  Future<void> removeSound(String id, {required bool isIqama}) async {
    final list = isIqama
        ? _settings.settings.customIqamas
        : _settings.settings.customAdhans;
    final entry = list.where((c) => c.id == id).firstOrNull;
    if (entry == null) return;
    emit(const CustomAdhanBusy());
    final result = await _delete(entry);
    result.fold((failure) => emit(CustomAdhanError(failure.message)), (
      _,
    ) async {
      if (isIqama) {
        await _settings.removeCustomIqama(id);
      } else {
        await _settings.removeCustomAdhan(id);
      }
      emit(const CustomAdhanIdle());
    });
  }

  Future<void> remove(String id) async {
    final entry = _settings.settings.customAdhans
        .where((c) => c.id == id)
        .firstOrNull;
    if (entry == null) return;
    emit(const CustomAdhanBusy());
    final result = await _delete(entry);
    result.fold((failure) => emit(CustomAdhanError(failure.message)), (
      _,
    ) async {
      await _settings.removeCustomAdhan(id);
      emit(const CustomAdhanIdle());
    });
  }

  Future<void> rename(String id, String newLabel) =>
      _settings.renameCustomAdhan(id, newLabel);

  /// Category-aware rename used by both the adhan and iqama pickers.
  Future<void> renameSound(
    String id,
    String newLabel, {
    required bool isIqama,
  }) => isIqama
      ? _settings.renameCustomIqama(id, newLabel)
      : _settings.renameCustomAdhan(id, newLabel);

  void clearError() {
    if (state is CustomAdhanError) emit(const CustomAdhanIdle());
  }

  String _deriveLabel(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final stem = dot > 0 ? fileName.substring(0, dot) : fileName;
    return stem.trim().isEmpty ? fileName : stem;
  }
}
