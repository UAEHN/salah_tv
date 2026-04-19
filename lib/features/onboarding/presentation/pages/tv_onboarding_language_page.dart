import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../onboarding_cubit.dart';
import '../widgets/tv_onboarding_lang_card.dart';

/// Step 0 of TV onboarding: pick Arabic or English.
class TvOnboardingLanguagePage extends StatelessWidget {
  const TvOnboardingLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final selected = context.select((OnboardingCubit c) => c.state.locale);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.onboardingWelcome,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l.onboardingChooseLanguage,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TvOnboardingLangCard(
              label: 'العربية',
              sublabel: 'Arabic',
              locale: 'ar',
              isSelected: selected == 'ar',
              autofocus: true,
            ),
            const SizedBox(width: 24),
            TvOnboardingLangCard(
              label: 'English',
              sublabel: 'الإنجليزية',
              locale: 'en',
              isSelected: selected == 'en',
            ),
          ],
        ),
      ],
    );
  }
}
