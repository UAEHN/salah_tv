import 'package:flutter/material.dart';

import 'onboarding_animation_utils.dart';

/// Shared entrance-animated scaffold for TV onboarding steps (country / city):
/// a staggered fade-in of a header, a horizontally-padded search area, and an
/// expanded body (list or results). Extracted from both step pages to keep
/// each under the 150-line cap and stay DRY (§4). The fade intervals match the
/// original per-page values, so the look is unchanged.
class TvOnboardingStepScaffold extends StatelessWidget {
  const TvOnboardingStepScaffold({
    super.key,
    required this.entrance,
    required this.header,
    required this.search,
    required this.body,
  });

  final Animation<double> entrance;
  final Widget header;
  final Widget search;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeTransition(
          opacity: onboardingInterval(parent: entrance, start: 0.0, end: 0.4),
          child: header,
        ),
        FadeTransition(
          opacity: onboardingInterval(parent: entrance, start: 0.2, end: 0.6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: search,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: FadeTransition(
            opacity: onboardingInterval(parent: entrance, start: 0.4, end: 1.0),
            child: body,
          ),
        ),
      ],
    );
  }
}
