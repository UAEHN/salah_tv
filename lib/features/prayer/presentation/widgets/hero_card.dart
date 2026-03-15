import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../makkah/presentation/makkah_stream_controller.dart';
import '../../../makkah/presentation/widgets/makkah_hero_content.dart';
import 'next_prayer_content.dart';
import 'iqama_content.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerState = context.watch<PrayerBloc>().state;
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    final isIqama = prayerState.isIqamaCountdown;
    final isMakkahActive = settings.isMakkahStreamEnabled &&
        !prayerState.isCycleActive &&
        prayerState.countdown.inSeconds > 120;

    // Only go borderless once the stream is actually playing (not during load/error)
    return ValueListenableBuilder<bool>(
      valueListenable: MakkahStreamController.isStreamPlaying,
      builder: (context, isVideoPlaying, _) {
        final isBorderless = isMakkahActive && isVideoPlaying;

        final decoration = isBorderless
            ? BoxDecoration(borderRadius: BorderRadius.circular(20))
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    palette.primary.withValues(alpha: 0.08),
                    palette.secondary.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: palette.primary.withValues(alpha: isIqama ? 0.7 : 0.4),
                  width: isIqama ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.glow.withValues(alpha: isIqama ? 0.2 : 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: isBorderless
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(
                  horizontal: screenW * 0.025,
                  vertical: screenH * 0.02,
                ),
          decoration: decoration,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: isIqama
                ? IqamaContent(key: const ValueKey('iqama'))
                : (isMakkahActive
                    ? _MakkahWrapper(key: const ValueKey('makkah'))
                    : NextPrayerContent(key: const ValueKey('next'))),
          ),
        );
      },
    );
  }
}

/// Wraps MakkahHeroContent and falls back to NextPrayerContent when the
/// stream is not yet playing (loading / error state).
class _MakkahWrapper extends StatelessWidget {
  const _MakkahWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fallback visible underneath; video covers it once playing.
        NextPrayerContent(key: const ValueKey('next_under_makkah')),
        // Video layer on top — SizedBox.shrink() when not playing.
        const MakkahHeroContent(),
      ],
    );
  }
}
