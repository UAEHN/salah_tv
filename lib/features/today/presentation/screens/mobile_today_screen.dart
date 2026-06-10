import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../settings/presentation/settings_provider.dart';
import '../bloc/today_cubit.dart';
import '../bloc/today_state.dart';
import '../logic/time_based_sky_gradient.dart';
import '../widgets/bento/bento_mushaf_continue_tile.dart';
import '../widgets/bento/bento_occasion_tile.dart';
import '../widgets/bento/bento_prayer_tile.dart';
import '../widgets/bento/bento_quick_actions_row.dart';
import '../widgets/bento/bento_tile.dart';
import '../widgets/bento/bento_time_dhikr_tile.dart';
import '../widgets/bento/bento_verse_tile.dart';
import '../widgets/today_parallax_sky.dart';
import '../widgets/today_staggered_entry.dart';
import '../widgets/today_top_meta.dart';

/// Bento Today screen.
///
/// Background:
///   • Light mode → time-of-day sky gradient (pre-fajr → night).
///   • Dark mode  → fixed premium night gradient (blue · violet · black).
///     The user opts into dark via Settings; hour-based shading is
///     suspended so the screen reads as a deliberate night canvas.
class MobileTodayScreen extends StatefulWidget {
  const MobileTodayScreen({super.key});

  @override
  State<MobileTodayScreen> createState() => _MobileTodayScreenState();
}

class _MobileTodayScreenState extends State<MobileTodayScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Backgrounds are theme-driven now (no longer time-of-day): a soft warm
    // beige in light mode, the premium night gradient in dark mode.
    final skyColors = isDark ? kPremiumNightGradient : kSoftLightGradient;

    final mq = MediaQuery.of(context);
    final fontFamily = context.select<SettingsProvider, String>(
      (p) => p.settings.fontFamily,
    );
    final isRubik = fontFamily == 'Rubik';
    final scaledMq = isRubik
        ? mq
        : mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 1.15,
              maxScaleFactor: 1.3,
            ),
          );
    return MediaQuery(
      data: scaledMq,
      child: BentoSurface(
        isDarkSky: isDark,
        child: Stack(
          children: [
            TodayParallaxSky(
              scrollController: _scrollController,
              colors: skyColors,
            ),
            SafeArea(
              bottom: false,
              child: _TodayBody(scrollController: _scrollController),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayBody extends StatelessWidget {
  final ScrollController scrollController;

  const _TodayBody({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodayCubit, TodayState>(
      builder: (context, state) {
        if (state is! TodayLoaded) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2.4),
          );
        }
        final settings = context.watch<SettingsProvider>().settings;
        final now = DateTime.now();
        final occasion = state.upcomingOccasion;
        final verse = state.dailyVerse;

        const stagger = Duration(milliseconds: 80);

        // Tightened spacing — the user wants the whole canvas visible
        // without scrolling on a typical phone (≈700px vertical body
        // budget). Bottom padding leaves room for the floating tab bar.
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
          physics: const BouncingScrollPhysics(),
          children: [
            TodayStaggeredEntry(
              delay: stagger * 0,
              child: TodayTopMeta(
                greeting: state.greeting,
                city: settings.selectedCity,
                country: settings.selectedCountry,
                now: now,
              ),
            ),
            const SizedBox(height: 10),
            // Row 1 — prayer hero. When an occasion is upcoming, share the
            // row with its tile (flex 7 / 4). Otherwise the prayer tile
            // takes the full width with a fixed height — `BentoPrayerTile`'s
            // internal Column uses Spacer(), which needs bounded vertical
            // space; the old layout got it from IntrinsicHeight + occasion
            // sibling, so we replace that anchor with a SizedBox here.
            TodayStaggeredEntry(
              delay: stagger * 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: occasion != null
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Expanded(flex: 7, child: BentoPrayerTile()),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: BentoOccasionTile(occasion: occasion),
                            ),
                          ],
                        ),
                      )
                    : const BentoPrayerTile(isExpanded: true),
              ),
            ),
            // Row 2 — verse of the day, full width.
            if (verse != null) ...[
              const SizedBox(height: 10),
              TodayStaggeredEntry(
                delay: stagger * 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BentoVerseTile(verse: verse),
                ),
              ),
            ],
            const SizedBox(height: 10),
            // Row 3a — «متابعة القراءة» shortcut (only when a bookmark
            // exists; the tile widget self-hides otherwise).
            TodayStaggeredEntry(
              delay: stagger * 3,
              child: const BentoMushafContinueTile(),
            ),
            const SizedBox(height: 10),
            // Row 3b — quick access (3 navigational tiles).
            TodayStaggeredEntry(
              delay: stagger * 4,
              child: const BentoQuickActionsRow(),
            ),
            const SizedBox(height: 10),
            // Row 4 — context-aware dhikr session for the current hour.
            TodayStaggeredEntry(
              delay: stagger * 5,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: BentoTimeDhikrTile(),
              ),
            ),
          ],
        );
      },
    );
  }
}
