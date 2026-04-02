import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/city_translations.dart';
import '../../../../features/settings/domain/entities/world_city.dart';
import '../../../../features/settings/presentation/widgets/mobile/mobile_location_search_field.dart';
import '../onboarding_cubit.dart';
import '../widgets/onboarding_animation_utils.dart';
import '../widgets/onboarding_next_button.dart';
import '../widgets/onboarding_page_header.dart';
import '../widgets/onboarding_selectable_tile.dart';
import '../widgets/onboarding_staggered_list.dart';

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
          entranceAnimation: widget.entranceAnimation,
          onBack: () {
            _searchController.clear();
            cubit.goBackToCountry();
          },
        ),
        const SizedBox(height: 4),
        FadeTransition(
          opacity: searchAnim,
          child: MobileLocationSearchField(
            controller: _searchController,
            hintText: l.settingsSearchCity,
            onChanged: (q) {
              setState(() {});
              cubit.filterCities(q);
            },
            onClear: _onClear,
            showClearIcon: true,
          ),
        ),
        Expanded(
          child: state.isSelectedCountryDb
              ? _DbCityList(
                  cities: state.filteredDbCities,
                  selectedCityKey: state.selectedCityKey,
                  entranceAnimation: widget.entranceAnimation,
                  locale: l.localeName,
                  onSelect: cubit.selectDbCity,
                )
              : _WorldCityList(
                  cities: state.filteredWorldCities,
                  selectedCity: state.selectedWorldCity,
                  entranceAnimation: widget.entranceAnimation,
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

class _DbCityList extends StatelessWidget {
  final List<String> cities;
  final String? selectedCityKey;
  final Animation<double> entranceAnimation;
  final String locale;
  final ValueChanged<String> onSelect;

  const _DbCityList({
    required this.cities,
    required this.selectedCityKey,
    required this.entranceAnimation,
    required this.locale,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStaggeredList(
      entranceAnimation: entranceAnimation,
      itemCount: cities.length,
      itemBuilder: (_, i) {
        final key = cities[i];
        final label = cityLabel(key, locale: locale);
        final isSelected = key == selectedCityKey;
        return OnboardingSelectableTile(
          title: label,
          isSelected: isSelected,
          onTap: () => onSelect(key),
        );
      },
    );
  }
}

class _WorldCityList extends StatelessWidget {
  final List<WorldCity> cities;
  final WorldCity? selectedCity;
  final Animation<double> entranceAnimation;
  final ValueChanged<WorldCity> onSelect;

  const _WorldCityList({
    required this.cities,
    required this.selectedCity,
    required this.entranceAnimation,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStaggeredList(
      entranceAnimation: entranceAnimation,
      itemCount: cities.length,
      itemBuilder: (_, i) {
        final city = cities[i];
        final isSelected =
            selectedCity?.name == city.name &&
            selectedCity?.countryKey == city.countryKey;
        return OnboardingSelectableTile(
          title: city.arabicName,
          isSelected: isSelected,
          onTap: () => onSelect(city),
        );
      },
    );
  }
}
