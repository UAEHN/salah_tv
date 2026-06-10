import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../features/prayer/presentation/bloc/prayer_bloc.dart';
import '../../../features/prayer/presentation/bloc/prayer_state.dart';
import '../../../features/settings/presentation/settings_provider.dart';
import '../domain/i_rating_service.dart';
import 'widgets/tv_rating_dialog.dart';

/// TV counterpart of [RatingTrigger].
/// Waits for 7+ days since install AND a calm prayer moment
/// (no active cycle, ≥5 min until next prayer) before showing [TvRatingDialog].
/// Static [_sessionShown] ensures one dialog per app session.
class TvRatingTrigger extends StatefulWidget {
  const TvRatingTrigger({super.key, required this.child});

  final Widget child;

  @override
  State<TvRatingTrigger> createState() => _TvRatingTriggerState();
}

class _TvRatingTriggerState extends State<TvRatingTrigger> {
  late final IRatingService _service;
  late final PrayerBloc _prayerBloc;
  StreamSubscription<PrayerState>? _sub;
  static bool _sessionShown = false;

  @override
  void initState() {
    super.initState();
    _service = GetIt.I<IRatingService>();
    _service.recordFirstLaunchIfNeeded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prayerBloc = context.read<PrayerBloc>();
      Future.delayed(const Duration(seconds: 10), _checkEligibility);
    });
  }

  Future<void> _checkEligibility() async {
    if (!mounted || _sessionShown) return;
    // Mosque mode: never interrupt a mosque wall display with a rating prompt.
    if (context.read<SettingsProvider>().settings.isMosqueMode) return;
    final canShow = kDebugMode || await _service.shouldShowDialog();
    if (!canShow) return;
    // Check current state immediately, then subscribe for future states.
    _onPrayerState(_prayerBloc.state);
    _sub = _prayerBloc.stream.listen(_onPrayerState);
  }

  void _onPrayerState(PrayerState state) {
    if (!mounted || _sessionShown) return;
    // Re-check mosque mode on every state — the user may toggle it on after
    // the initial eligibility check has already passed and we are subscribed.
    if (context.read<SettingsProvider>().settings.isMosqueMode) return;
    final isCalmMoment =
        !state.isCycleActive &&
        state.todayPrayers != null &&
        state.countdown.inMinutes >= 5;
    if (!isCalmMoment) return;

    _sub?.cancel();
    _sub = null;
    _sessionShown = true;
    _showDialog();
  }

  Future<void> _showDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TvRatingDialog(service: _service),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
