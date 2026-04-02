import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_cubit.dart';
import 'pages/onboarding_city_page.dart';
import 'pages/onboarding_country_page.dart';
import 'pages/onboarding_language_page.dart';
import 'widgets/onboarding_background.dart';
import 'widgets/onboarding_progress_bar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _entranceController;
  late final AnimationController _shimmerController;

  int _prevStep = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _shimmerController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _triggerEntrance() {
    _entranceController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) =>
          curr.isComplete || prev.step != curr.step,
      listener: (context, state) {
        if (state.isComplete) {
          Navigator.of(context).pushReplacementNamed('/');
          return;
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
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    OnboardingProgressBar(
                      currentStep: state.step,
                      shimmerAnimation: _shimmerController,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final isForward =
                              (child.key as ValueKey<int>?)?.value ==
                                  state.step;
                          final beginOffset = isForward
                              ? const Offset(0.07, 0)
                              : const Offset(-0.07, 0);
                          return SlideTransition(
                            position: Tween(
                              begin: beginOffset,
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: _pageForStep(state.step),
                      ),
                    ),
                  ],
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
        return OnboardingCountryPage(
          key: const ValueKey(1),
          entranceAnimation: _entranceController,
        );
      case 2:
        return OnboardingCityPage(
          key: const ValueKey(2),
          entranceAnimation: _entranceController,
        );
      default:
        return OnboardingLanguagePage(
          key: const ValueKey(0),
          entranceAnimation: _entranceController,
          shimmerAnimation: _shimmerController,
        );
    }
  }
}
