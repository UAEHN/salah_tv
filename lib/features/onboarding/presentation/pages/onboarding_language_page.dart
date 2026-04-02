import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../onboarding_cubit.dart';
import '../widgets/onboarding_animation_utils.dart';
import '../widgets/onboarding_language_card.dart';
import '../widgets/onboarding_next_button.dart';
import '../widgets/onboarding_page_header.dart';

class OnboardingLanguagePage extends StatelessWidget {
  final Animation<double> entranceAnimation;
  final Animation<double> shimmerAnimation;

  const OnboardingLanguagePage({
    super.key,
    required this.entranceAnimation,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<OnboardingCubit>().state;
    final selectedLocale = state.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingPageHeader(
          title: l.onboardingWelcome,
          subtitle: l.onboardingChooseLanguage,
          entranceAnimation: entranceAnimation,
          shimmerAnimation: shimmerAnimation,
        ),
        const SizedBox(height: 24),
        _LanguageCardWithDelay(
          delay: 0.0,
          locale: 'ar',
          label: l.languageArabic,
          nativeLabel: 'العربية',
          icon: Icons.translate_rounded,
          isSelected: selectedLocale == 'ar',
          onTap: () => context.read<OnboardingCubit>().selectLanguage('ar'),
          entranceAnimation: entranceAnimation,
        ),
        _LanguageCardWithDelay(
          delay: 0.1,
          locale: 'en',
          label: l.languageEnglish,
          nativeLabel: 'English',
          icon: Icons.language_rounded,
          isSelected: selectedLocale == 'en',
          onTap: () => context.read<OnboardingCubit>().selectLanguage('en'),
          entranceAnimation: entranceAnimation,
        ),
        const Spacer(),
        OnboardingNextButton(
          label: l.onboardingNext,
          onTap: () => context.read<OnboardingCubit>().advanceToCountry(),
          entranceAnimation: entranceAnimation,
        ),
      ],
    );
  }
}

class _LanguageCardWithDelay extends StatelessWidget {
  final double delay;
  final String locale;
  final String label;
  final String nativeLabel;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double> entranceAnimation;

  const _LanguageCardWithDelay({
    required this.delay,
    required this.locale,
    required this.label,
    required this.nativeLabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.entranceAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final start = 0.1 + delay;
    final end = (start + 0.5).clamp(0.0, 1.0);
    final anim = onboardingInterval(
      parent: entranceAnimation,
      start: start,
      end: end,
      curve: Curves.easeOutCubic,
    );
    return OnboardingLanguageCard(
      locale: locale,
      label: label,
      nativeLabel: nativeLabel,
      icon: icon,
      isSelected: isSelected,
      onTap: onTap,
      entranceAnimation: anim,
    );
  }
}
