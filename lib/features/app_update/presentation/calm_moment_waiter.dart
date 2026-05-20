import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../prayer/presentation/bloc/prayer_state.dart';

/// Waits for a "calm moment" in the prayer cycle before invoking [onCalm].
/// Mirrors the same guard used by `TvRatingTrigger`: no active cycle and
/// at least 5 minutes until the next prayer.
///
/// Owned by a `State` so the caller is responsible for `dispose()`.
class CalmMomentWaiter {
  CalmMomentWaiter({
    required this.context,
    required this.onCalm,
    required this.isStillActive,
  });

  final BuildContext context;
  final VoidCallback onCalm;
  final ValueGetter<bool> isStillActive;

  StreamSubscription<PrayerState>? _sub;
  // Guards against re-firing `onCalm` when the bloc emits a fresh state on
  // the very next tick after the synchronous initial evaluation has already
  // fired. Without this flag the dialog could be pushed twice.
  bool _fired = false;

  void start() {
    if (!isStillActive()) return;
    final bloc = context.read<PrayerBloc>();
    // Subscribe FIRST so `dispose()` inside `_evaluate` actually cancels.
    _sub = bloc.stream.listen(_evaluate);
    _evaluate(bloc.state);
  }

  void _evaluate(PrayerState state) {
    if (_fired || !isStillActive()) return;
    final isCalm = !state.isCycleActive &&
        state.todayPrayers != null &&
        state.countdown.inMinutes >= 5;
    if (!isCalm) return;
    _fired = true;
    dispose();
    onCalm();
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
