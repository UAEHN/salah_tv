import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_cubit.dart';
import 'pages/tv_onboarding_city_page.dart';
import 'pages/tv_onboarding_country_page.dart';
import 'pages/tv_onboarding_language_page.dart';
import 'widgets/onboarding_background.dart';

/// TV counterpart of [OnboardingScreen].
/// Three steps: Language (0) → Country (1) → City (2).
/// Reuses [OnboardingCubit] for all business logic (DRY).
/// Layout: starfield background + centred glass card.
class TvOnboardingScreen extends StatefulWidget {
  const TvOnboardingScreen({super.key});

  @override
  State<TvOnboardingScreen> createState() => _TvOnboardingScreenState();
}

class _TvOnboardingScreenState extends State<TvOnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _entranceController;

  int _prevStep = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _triggerEntrance() => _entranceController.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) =>
          curr.isComplete ||
          prev.step != curr.step ||
          prev.completionError != curr.completionError,
      listener: (context, state) {
        if (state.isComplete) {
          Navigator.of(context).pushReplacementNamed('/');
          return;
        }
        if (state.completionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.completionError!),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
          context.read<OnboardingCubit>().clearCompletionError();
        }
        if (state.step != _prevStep) {
          _prevStep = state.step;
          _triggerEntrance();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF050A18),
          body: Stack(
            fit: StackFit.expand,
            children: [
              OnboardingBackground(starsAnimation: _bgController),
              _TvStepIndicator(currentStep: state.step),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeIn,
                  child: _pageForStep(state.step),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pageForStep(int step) {
    switch (step) {
      case 1:
        return TvOnboardingCountryPage(
          key: const ValueKey(1),
          entranceAnimation: _entranceController,
        );
      case 2:
        return TvOnboardingCityPage(
          key: const ValueKey(2),
          entranceAnimation: _entranceController,
        );
      default:
        return const TvOnboardingLanguagePage(key: ValueKey(0));
    }
  }
}

// ─── Step indicator ───────────────────────────────────────────────────────────

class _TvStepIndicator extends StatelessWidget {
  const _TvStepIndicator({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final isActive = i <= currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == currentStep ? 28 : 10,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isActive
                  ? const Color(0xFFD4A843)
                  : Colors.white.withValues(alpha: 0.2),
            ),
          );
        }),
      ),
    );
  }
}
