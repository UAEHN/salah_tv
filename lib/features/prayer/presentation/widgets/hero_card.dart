import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../../../../injection.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_state.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../adhkar/domain/entities/adhkar_session.dart';
import '../../../adhkar/domain/i_adhkar_state_repository.dart';
import 'adhkar_hero_content.dart';
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
    final session = sessionFromNextPrayer(prayerState.nextPrayerKey);
    final adhkarRepo = getIt<IAdhkarStateRepository>();
    // Show if: not shown today OR session is currently active (don't interrupt).
    final canShowAdhkar = session == AdhkarSession.morning
        ? (!adhkarRepo.hasMorningAdhkarShownToday() || adhkarRepo.isMorningSessionActive)
        : (!adhkarRepo.hasEveningAdhkarShownToday() || adhkarRepo.isEveningSessionActive);
    // Morning: hide from 10:00 AM onward. Evening: hide 15 min before prayer.
    final isTimeValid = session == AdhkarSession.morning
        ? DateTime.now().hour < 10
        : prayerState.countdown.inSeconds > 15 * 60;
    final isAdhkarActive =
        settings.isAdhkarEnabled &&
        !prayerState.isCycleActive &&
        session != AdhkarSession.none &&
        canShowAdhkar &&
        isTimeValid;

    return BlocListener<PrayerBloc, PrayerState>(
      listenWhen: (prev, curr) {
        // Fires once when morning window closes while app is running.
        // Marks today as done so adhkar never re-appear outside the window.
        final prevOpen =
            sessionFromNextPrayer(prev.nextPrayerKey) == AdhkarSession.morning &&
            prev.countdown.inSeconds > 15 * 60;
        final currClosed =
            sessionFromNextPrayer(curr.nextPrayerKey) != AdhkarSession.morning ||
            curr.countdown.inSeconds <= 15 * 60;
        return prevOpen && currClosed;
      },
      listener: (context, state) {
        final repo = getIt<IAdhkarStateRepository>();
        if (!repo.hasMorningAdhkarShownToday()) repo.startMorningSession();
      },
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.025,
        vertical: screenH * 0.02,
      ),
      decoration: BoxDecoration(
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
      ),
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
            : isAdhkarActive
                ? AdhkarHeroContent(
                    key: ValueKey('adhkar_${session.name}'),
                    session: session,
                  )
                : NextPrayerContent(key: const ValueKey('next')),
      ),
      ),
    );
  }
}
