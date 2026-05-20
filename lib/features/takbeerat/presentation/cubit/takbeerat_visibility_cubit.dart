import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/eid_visibility.dart';
import '../../domain/entities/takbeerat_reciter.dart';
import '../../domain/i_takbeerat_config_repository.dart';
import '../../domain/usecases/should_show_takbeerat_card.dart';
import 'takbeerat_visibility_state.dart';

/// Drives the Eid Takbeerat home card. State is hidden until [load]
/// resolves, so a card placed in the tree renders zero pixels at first.
///
/// Failures degrade silently to hidden: a flaky Remote Config fetch must
/// never make a religious banner flicker on/off in front of users.
class TakbeeratVisibilityCubit extends Cubit<TakbeeratVisibilityState> {
  TakbeeratVisibilityCubit({
    required ShouldShowTakbeeratCard shouldShow,
    required ITakbeeratConfigRepository configRepo,
  })  : _shouldShow = shouldShow,
        _configRepo = configRepo,
        super(TakbeeratVisibilityState.hidden());

  final ShouldShowTakbeeratCard _shouldShow;
  final ITakbeeratConfigRepository _configRepo;

  /// Resolves visibility and reciter catalogue. Safe to call repeatedly.
  Future<void> load({DateTime? now}) async {
    final visibilityResult = await _shouldShow(now ?? DateTime.now());
    final visibility = visibilityResult.fold<EidVisibility>(
      (_) => EidVisibility.hidden(),
      (v) => v,
    );
    if (!visibility.hasCard) {
      emit(TakbeeratVisibilityState.hidden());
      return;
    }
    final configResult = await _configRepo.fetchConfig();
    final reciters = configResult.fold<List<TakbeeratReciter>>(
      (_) => const <TakbeeratReciter>[],
      (cfg) => cfg.reciters,
    );
    emit(TakbeeratVisibilityState(
      visibility: visibility,
      reciters: reciters,
    ));
  }
}
