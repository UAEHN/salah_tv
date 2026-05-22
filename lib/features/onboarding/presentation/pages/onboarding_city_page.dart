import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/city_translations.dart';
import '../onboarding_cubit.dart';
import '../widgets/onboarding_animation_utils.dart';
import '../widgets/onboarding_city_lists.dart';
import '../widgets/onboarding_next_button.dart';
import '../widgets/onboarding_page_header.dart';
import '../widgets/onboarding_search_field.dart';

class OnboardingCityPage extends StatefulWidget {
  final Animation<double> entranceAnimation;

  const OnboardingCityPage({super.key, required this.entranceAnimation});

  @override
  State<OnboardingCityPage> createState() => _OnboardingCityPageState();
}

class _OnboardingCityPageState extends State<OnboardingCityPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onClear() {
    _searchController.clear();
    context.read<OnboardingCubit>().filterCities('');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<OnboardingCubit>();
    final state = context.watch<OnboardingCubit>().state;

    final countryName = state.selectedCountryKey != null
        ? countryLabel(state.selectedCountryKey!, locale: l.localeName)
        : '';
    final searchAnim = onboardingInterval(
      parent: widget.entranceAnimation,
      start: 0.15,
      end: 0.6,
    );
    final hasSelection =
        state.selectedCityKey != null || state.selectedWorldCity != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingPageHeader(
          title: countryName,
          subtitle: l.onboardingSelectCity,
          onBack: () {
            _searchController.clear();
            cubit.goBackToCountry();
          },
        ),
        const SizedBox(height: 10),
        FadeTransition(
          opacity: searchAnim,
          child: OnboardingSearchField(
            controller: _searchController,
            hintText: l.settingsSearchCity,
            onChanged: (q) {
              setState(() {});
              cubit.filterCities(q);
            },
            onClear: _onClear,
          ),
        ),
        Expanded(
          child: state.isSelectedCountryDb
              ? OnboardingDbCityList(
                  cities: state.filteredDbCities,
                  selectedCityKey: state.selectedCityKey,
                  entranceAnimation: widget.entranceAnimation,
                  locale: l.localeName,
                  onSelect: cubit.selectDbCity,
                )
              : OnboardingWorldCityList(
                  cities: state.filteredWorldCities,
                  selectedCity: state.selectedWorldCity,
                  entranceAnimation: widget.entranceAnimation,
                  locale: l.localeName,
                  onSelect: cubit.selectWorldCity,
                ),
        ),
        OnboardingFinishButton(
          label: l.onboardingFinish,
          onTap: cubit.complete,
          isLoading: state.isLoading,
          isVisible: hasSelection,
        ),
      ],
    );
  }
}
