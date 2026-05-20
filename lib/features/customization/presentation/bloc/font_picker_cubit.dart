import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/domain/i_analytics_service.dart';
import '../../domain/usecases/apply_quran_font.dart';
import '../../domain/usecases/get_all_quran_fonts.dart';
import 'font_picker_state.dart';

class FontPickerCubit extends Cubit<FontPickerState> {
  final GetAllQuranFontsUseCase _getAll;
  final ApplyQuranFontUseCase _apply;
  final IAnalyticsService? _analytics;

  FontPickerCubit({
    required GetAllQuranFontsUseCase getAll,
    required ApplyQuranFontUseCase apply,
    IAnalyticsService? analytics,
  })  : _getAll = getAll,
        _apply = apply,
        _analytics = analytics,
        super(const FontPickerInitial());

  Future<void> load(String currentFamily) async {
    emit(const FontPickerLoading());
    final result = await _getAll();
    result.fold(
      (failure) => emit(const FontPickerError('fontPickerLoadError')),
      (fonts) => emit(
        FontPickerLoaded(fonts: fonts, selectedFamily: currentFamily),
      ),
    );
  }

  Future<void> select(String family) async {
    final current = state;
    if (current is! FontPickerLoaded) return;
    if (current.isApplying) return;
    if (family == current.selectedFamily) return;

    final previousFamily = current.selectedFamily;
    emit(current.copyWith(selectedFamily: family, isApplying: true));

    final result = await _apply(family);
    result.fold(
      (failure) {
        emit(current.copyWith(selectedFamily: previousFamily, isApplying: false));
      },
      (_) {
        _analytics?.logFontChanged(family);
        final latest = state;
        if (latest is FontPickerLoaded) {
          emit(latest.copyWith(isApplying: false));
        }
      },
    );
  }
}
