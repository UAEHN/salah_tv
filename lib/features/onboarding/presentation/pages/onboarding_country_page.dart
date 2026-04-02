import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../features/settings/domain/entities/detected_location.dart';
import '../../../../features/settings/presentation/widgets/mobile/mobile_detect_location_button.dart';
import '../../../../features/settings/presentation/widgets/mobile/mobile_location_search_field.dart';
import '../../../../features/settings/presentation/widgets/mobile/mobile_location_search_utils.dart';
import '../onboarding_cubit.dart';
import '../widgets/onboarding_animation_utils.dart';
import '../widgets/onboarding_page_header.dart';
import '../widgets/onboarding_selectable_tile.dart';
import '../widgets/onboarding_staggered_list.dart';

class OnboardingCountryPage extends StatefulWidget {
  final Animation<double> entranceAnimation;

  const OnboardingCountryPage({super.key, required this.entranceAnimation});

  @override
  State<OnboardingCountryPage> createState() => _OnboardingCountryPageState();
}

class _OnboardingCountryPageState extends State<OnboardingCountryPage> {
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
    context.read<OnboardingCubit>().filterCountries('');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<OnboardingCubit>().state;
    final btnAnim = onboardingInterval(
      parent: widget.entranceAnimation,
      start: 0.1,
      end: 0.55,
    );
    final searchAnim = onboardingInterval(
      parent: widget.entranceAnimation,
      start: 0.2,
      end: 0.65,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingPageHeader(
          title: l.onboardingSelectCountry,
          entranceAnimation: widget.entranceAnimation,
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: btnAnim,
          child: SlideTransition(
            position: onboardingSlideIn(
              parent: widget.entranceAnimation,
              start: 0.1,
              end: 0.55,
            ),
            child: MobileDetectLocationButton(
              onDetected: (DetectedLocation loc) =>
                  context.read<OnboardingCubit>().onLocationDetected(loc),
            ),
          ),
        ),
        FadeTransition(
          opacity: searchAnim,
          child: MobileLocationSearchField(
            controller: _searchController,
            hintText: l.settingsSearchCountry,
            onChanged: (q) {
              setState(() {});
              context.read<OnboardingCubit>().filterCountries(q);
            },
            onClear: _onClear,
            showClearIcon: true,
          ),
        ),
        Expanded(
          child: state.filteredCountries.isEmpty
              ? _buildCountriesWithStagger(state.allCountries)
              : _buildCountriesWithStagger(state.filteredCountries),
        ),
      ],
    );
  }

  Widget _buildCountriesWithStagger(List<UnifiedCountry> countries) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<OnboardingCubit>();
    final state = cubit.state;
    return OnboardingStaggeredList(
      entranceAnimation: widget.entranceAnimation,
      itemCount: countries.length,
      itemBuilder: (_, i) {
        final country = countries[i];
        final isSelected = country.key == state.selectedCountryKey;
        return OnboardingSelectableTile(
          title: l.localeName == 'en'
              ? country.englishName
              : country.arabicName,
          isSelected: isSelected,
          onTap: () => cubit.selectCountry(country.key),
        );
      },
    );
  }
}
