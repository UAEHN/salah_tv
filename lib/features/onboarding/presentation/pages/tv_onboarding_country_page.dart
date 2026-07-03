import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/calculated_times_notice_dialog.dart';
import '../../../../core/widgets/worldwide_search_hint.dart';
import '../../../../injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/data/online_result_to_detected_location.dart';
import '../../../settings/domain/entities/online_geocoding_result.dart';
import '../../../settings/domain/i_online_geocoding_repository.dart';
import '../../../settings/presentation/bloc/online_geocoding_cubit.dart';
import '../onboarding_cubit.dart';
import '../widgets/onboarding_unified_search_results.dart';
import '../widgets/tv_onboarding_country_list.dart';
import '../widgets/tv_onboarding_search_field.dart';
import '../widgets/tv_onboarding_step_scaffold.dart';

/// Onboarding accent (gold) — matches the TV start-screen theme.
const Color _kOnboardingAccent = Color(0xFFD4A843);

/// Step 1 of TV onboarding: pick a country from the list, or — when the country
/// isn't supported — search any city worldwide online (Nominatim). World picks
/// are calculated, so the calculated-times notice is shown before committing.
class TvOnboardingCountryPage extends StatefulWidget {
  const TvOnboardingCountryPage({super.key, required this.entranceAnimation});

  final Animation<double> entranceAnimation;

  @override
  State<TvOnboardingCountryPage> createState() =>
      _TvOnboardingCountryPageState();
}

class _TvOnboardingCountryPageState extends State<TvOnboardingCountryPage> {
  final _searchController = TextEditingController();
  late final OnlineGeocodingCubit _onlineCubit;

  @override
  void initState() {
    super.initState();
    _onlineCubit = OnlineGeocodingCubit(getIt<IOnlineGeocodingRepository>());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _onlineCubit.close();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    context.read<OnboardingCubit>().filterCountries(query);
    _onlineCubit.searchDebounced(query);
  }

  /// Online (worldwide) picks have no official table — confirm the calculated
  /// notice, then resolve + commit the location and finish onboarding.
  Future<void> _onSelectOnline(OnlineGeocodingResult r) async {
    final cubit = context.read<OnboardingCubit>();
    final confirmed = await CalculatedTimesNoticeDialog.show(
      context,
      accent: _kOnboardingAccent,
    );
    if (confirmed != true || !mounted) return;
    final detected = await detectedLocationFromOnlineResult(
      r,
      worldRepo: cubit.state.worldRepo,
    );
    if (!mounted) return;
    await cubit.selectOnlineLocationAndComplete(detected);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<OnboardingCubit>().state;
    final cubit = context.read<OnboardingCubit>();
    final hasQuery = _searchController.text.trim().length >= 2;
    // No local country matched the query → offer worldwide online search.
    final showOnline = hasQuery && state.filteredCountries.isEmpty;
    final countries = state.filteredCountries.isNotEmpty
        ? state.filteredCountries
        : state.allCountries;

    return TvOnboardingStepScaffold(
      entrance: widget.entranceAnimation,
      header: Padding(
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
      search: Column(
        children: [
          TvOnboardingSearchField(
            controller: _searchController,
            hint: l.settingsSearchCountry,
            onChanged: _onQueryChanged,
          ),
          const SizedBox(height: 12),
          WorldwideSearchHint(
            textColor: Colors.white.withValues(alpha: 0.55),
            accentColor: _kOnboardingAccent,
          ),
        ],
      ),
      body: showOnline
          ? BlocBuilder<OnlineGeocodingCubit, OnlineGeocodingState>(
              bloc: _onlineCubit,
              builder: (_, st) => OnboardingUnifiedSearchResults(
                state: st,
                onSelect: _onSelectOnline,
              ),
            )
          : TvOnboardingCountryList(
              countries: countries,
              selectedKey: state.selectedCountryKey,
              locale: l.localeName,
              onSelect: cubit.selectCountry,
            ),
    );
  }
}
