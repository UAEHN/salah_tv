import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> pickAndImport(String label) async {
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
    result.fold(
      (failure) => emit(CustomAdhanError(failure.message)),
      (custom) async {
        await _settings.addCustomAdhan(custom);
        emit(const CustomAdhanIdle());
      },
    );
  }

  Future<void> remove(String id) async {
    final entry = _settings.settings.customAdhans
        .where((c) => c.id == id)
        .firstOrNull;
    if (entry == null) return;
    emit(const CustomAdhanBusy());
    final result = await _delete(entry);
    result.fold((failure) => emit(CustomAdhanError(failure.message)), (_) async {
      await _settings.removeCustomAdhan(id);
      emit(const CustomAdhanIdle());
    });
  }

  Future<void> rename(String id, String newLabel) =>
      _settings.renameCustomAdhan(id, newLabel);

  void clearError() {
    if (state is CustomAdhanError) emit(const CustomAdhanIdle());
  }

  String _deriveLabel(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final stem = dot > 0 ? fileName.substring(0, dot) : fileName;
    return stem.trim().isEmpty ? fileName : stem;
  }
}
