import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/i_adhan_preview_port.dart';

sealed class AdhanPreviewState {
  const AdhanPreviewState();
}

class AdhanPreviewIdle extends AdhanPreviewState {
  const AdhanPreviewIdle();
}

class AdhanPreviewPlaying extends AdhanPreviewState {
  final String soundKey;
  const AdhanPreviewPlaying(this.soundKey);
}

class AdhanPreviewCubit extends Cubit<AdhanPreviewState> {
  final IAdhanPreviewPort _previewPort;

  AdhanPreviewCubit(this._previewPort) : super(const AdhanPreviewIdle());

  Future<void> toggle(String soundKey) async {
    final current = state;
    if (current is AdhanPreviewPlaying && current.soundKey == soundKey) {
      await _previewPort.stop();
      emit(const AdhanPreviewIdle());
    } else {
      emit(AdhanPreviewPlaying(soundKey));
      await _previewPort.preview(soundKey);
    }
  }

  @override
  Future<void> close() async {
    await _previewPort.stop();
    return super.close();
  }
}
