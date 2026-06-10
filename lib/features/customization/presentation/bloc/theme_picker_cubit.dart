import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/domain/i_analytics_service.dart';
import '../../domain/usecases/apply_theme_palette.dart';
import '../../domain/usecases/get_all_theme_palettes.dart';
import 'theme_picker_state.dart';

class ThemePickerCubit extends Cubit<ThemePickerState> {
  final GetAllThemePalettesUseCase _getAll;
  final ApplyThemePaletteUseCase _apply;
  final IAnalyticsService? _analytics;

  ThemePickerCubit({
    required GetAllThemePalettesUseCase getAll,
    required ApplyThemePaletteUseCase apply,
    IAnalyticsService? analytics,
  }) : _getAll = getAll,
       _apply = apply,
       _analytics = analytics,
       super(const ThemePickerInitial());

  Future<void> load(String currentSelectedId) async {
    emit(const ThemePickerLoading());
    final result = await _getAll();
    result.fold(
      (failure) => emit(const ThemePickerError('themePickerLoadError')),
      (palettes) => emit(
        ThemePickerLoaded(palettes: palettes, selectedId: currentSelectedId),
      ),
    );
  }

  Future<void> select(String paletteId) async {
    final current = state;
    if (current is! ThemePickerLoaded) return;
    if (current.isApplying) return;
    if (paletteId == current.selectedId) return;

    // Optimistic UI: flip the selection + lock further taps while we persist.
    final previousId = current.selectedId;
    emit(current.copyWith(selectedId: paletteId, isApplying: true));

    final result = await _apply(paletteId);
    result.fold(
      (failure) {
        emit(current.copyWith(selectedId: previousId, isApplying: false));
      },
      (_) {
        _analytics?.logThemeChanged(paletteId);
        final latest = state;
        if (latest is ThemePickerLoaded) {
          emit(latest.copyWith(isApplying: false));
        }
      },
    );
  }
}
