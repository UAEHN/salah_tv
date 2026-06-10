import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../onboarding_cubit.dart';
import '../widgets/onboarding_animation_utils.dart';
import '../widgets/tv_onboarding_city_list_views.dart';
import '../widgets/tv_onboarding_search_field.dart';

/// Step 2 of TV onboarding: pick a city after country is selected.
class TvOnboardingCityPage extends StatefulWidget {
  const TvOnboardingCityPage({super.key, required this.entranceAnimation});

  final Animation<double> entranceAnimation;

  @override
  State<TvOnboardingCityPage> createState() => _TvOnboardingCityPageState();
}

class _TvOnboardingCityPageState extends State<TvOnboardingCityPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<OnboardingCubit>().state;
    final cubit = context.read<OnboardingCubit>();

    return Column(
      children: [
        // ── Top: Back Button + Title ─────────────────────────────────────
        FadeTransition(
          opacity: onboardingInterval(
            parent: widget.entranceAnimation,
            start: 0.0,
            end: 0.4,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: Column(
              children: [
                _BackButton(
                  onPressed: () {
                    _searchController.clear();
                    cubit.goBackToCountry();
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  l.onboardingSelectCity,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // ── Middle: Search ───────────────────────────────────────────────
        FadeTransition(
          opacity: onboardingInterval(
            parent: widget.entranceAnimation,
            start: 0.2,
            end: 0.6,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: TvOnboardingSearchField(
              controller: _searchController,
              hint: l.settingsSearchCity,
              onChanged: cubit.filterCities,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ── Bottom: Scrollable List ──────────────────────────────────────
        Expanded(
          child: FadeTransition(
            opacity: onboardingInterval(
              parent: widget.entranceAnimation,
              start: 0.4,
              end: 1.0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: state.isSelectedCountryDb
                  ? DbCityListView(
                      cities: state.filteredDbCities,
                      selectedKey: state.selectedCityKey,
                      locale: l.localeName,
                      onSelect: cubit.selectDbCityAndComplete,
                    )
                  : WorldCityListView(
                      cities: state.filteredWorldCities,
                      selectedCity: state.selectedWorldCity,
                      locale: l.localeName,
                      onSelect: cubit.selectWorldCityAndComplete,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Back button ──────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back_rounded,
            color: Colors.white.withValues(alpha: 0.5),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context).onboardingSelectCountry,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
