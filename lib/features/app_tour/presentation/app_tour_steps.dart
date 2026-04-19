import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../core/widgets/mobile/tour_target_keys.dart';
import 'widgets/tour_tooltip.dart';

List<TargetFocus> buildTourSteps(TourTargetKeys keys, AppLocalizations l) {
  final steps = <_StepDef>[
    _StepDef(
      key: keys.countdown,
      title: l.tourStepCountdownTitle,
      description: l.tourStepCountdownDesc,
      align: ContentAlign.bottom,
    ),
    _StepDef(
      key: keys.prayerList,
      title: l.tourStepPrayerListTitle,
      description: l.tourStepPrayerListDesc,
      align: ContentAlign.top,
    ),
    _StepDef(
      key: keys.dateNavigator,
      title: l.tourStepDateNavTitle,
      description: l.tourStepDateNavDesc,
      align: ContentAlign.bottom,
    ),
    _StepDef(
      key: keys.locationPill,
      title: l.tourStepLocationTitle,
      description: l.tourStepLocationDesc,
      align: ContentAlign.bottom,
    ),
    _StepDef(
      key: keys.bottomNav,
      title: l.tourStepBottomNavTitle,
      description: l.tourStepBottomNavDesc,
      align: ContentAlign.top,
    ),
  ];

  return List.generate(steps.length, (i) {
    final step = steps[i];
    return TargetFocus(
      identify: 'step_$i',
      keyTarget: step.key,
      alignSkip: Alignment.topLeft,
      shape: ShapeLightFocus.RRect,
      radius: 12,
      contents: [
        TargetContent(
          align: step.align,
          child: TourTooltip(
            title: step.title,
            description: step.description,
            currentStep: i + 1,
            totalSteps: steps.length,
            skipLabel: l.tourSkip,
            nextLabel: i < steps.length - 1 ? l.tourNext : l.tourFinish,
          ),
        ),
      ],
    );
  });
}

class _StepDef {
  final GlobalKey key;
  final String title;
  final String description;
  final ContentAlign align;

  const _StepDef({
    required this.key,
    required this.title,
    required this.description,
    required this.align,
  });
}
