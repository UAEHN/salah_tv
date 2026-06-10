import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../onboarding_cubit.dart';
import '../widgets/onboarding_animation_utils.dart';
import '../widgets/tv_onboarding_list_item.dart';
import '../widgets/tv_onboarding_search_field.dart';

/// Step 1 of TV onboarding: pick a country from a scrollable list.
class TvOnboardingCountryPage extends StatefulWidget {
  const TvOnboardingCountryPage({super.key, required this.entranceAnimation});

  final Animation<double> entranceAnimation;

  @override
  State<TvOnboardingCountryPage> createState() =>
      _TvOnboardingCountryPageState();
}

class _TvOnboardingCountryPageState extends State<TvOnboardingCountryPage> {
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
    final countries = state.filteredCountries.isNotEmpty
        ? state.filteredCountries
        : state.allCountries;

    return Column(
      children: [
        // ── Top: Title ───────────────────────────────────────────────────
        FadeTransition(
          opacity: onboardingInterval(
            parent: widget.entranceAnimation,
            start: 0.0,
            end: 0.4,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 24),
            child: Text(
              l.onboardingSelectCountry,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
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
              hint: l.settingsSearchCountry,
              onChanged: cubit.filterCountries,
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
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 64, right: 64, bottom: 32),
              itemCount: countries.length,
              itemBuilder: (_, i) {
                final country = countries[i];
                final label = l.localeName == 'en'
                    ? country.englishName
                    : country.arabicName;
                return TvOnboardingListItem(
                  title: label,
                  isSelected: country.key == state.selectedCountryKey,
                  onSelect: () => cubit.selectCountry(country.key),
                  autofocus: i == 0,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
