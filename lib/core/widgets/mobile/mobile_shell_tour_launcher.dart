import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../features/app_tour/presentation/app_tour_cubit.dart';
import '../../../features/app_tour/presentation/app_tour_steps.dart';
import 'tour_target_keys.dart';

/// Listens to [AppTourCubit] and launches the spotlight tour overlay.
/// Auto-advances to the next step after 5s of inactivity.
class MobileShellTourLauncher extends StatelessWidget {
  final TourTargetKeys tourKeys;
  final Widget child;

  const MobileShellTourLauncher({
    super.key,
    required this.tourKeys,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppTourCubit, AppTourState>(
      listenWhen: (prev, curr) =>
          curr.status == AppTourStatus.requested &&
          prev.status != AppTourStatus.requested,
      listener: (context, state) => _launchTour(context),
      child: child,
    );
  }

  void _launchTour(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<AppTourCubit>();
    final steps = buildTourSteps(tourKeys, l);
    final holder = _TimerHolder();

    late final TutorialCoachMark tutorial;
    tutorial = TutorialCoachMark(
      targets: steps,
      colorShadow: const Color(0xFF050A18),
      opacityShadow: 0.85,
      textSkip: l.tourSkip,
      textStyleSkip: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontFamily: 'Cairo',
      ),
      paddingFocus: 8,
      onClickTarget: (_) => holder.restart(tutorial),
      onClickOverlay: (_) => holder.restart(tutorial),
      onFinish: () {
        holder.cancel();
        cubit.completeTour();
      },
      onSkip: () {
        holder.cancel();
        cubit.skipTour();
        return true;
      },
    );

    holder.restart(tutorial);
    tutorial.show(context: context);
  }
}

class _TimerHolder {
  static const _delay = Duration(seconds: 5);
  Timer? _timer;

  void restart(TutorialCoachMark tutorial) {
    _timer?.cancel();
    _timer = Timer(_delay, () => tutorial.next());
  }

  void cancel() => _timer?.cancel();
}
