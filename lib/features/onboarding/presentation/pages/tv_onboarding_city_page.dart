import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/calculated_times_notice_dialog.dart';
import '../../../../features/settings/domain/entities/world_city.dart';
import '../../../../l10n/app_localizations.dart';
import '../onboarding_cubit.dart';
import '../widgets/tv_onboarding_city_list_views.dart';
import '../widgets/tv_onboarding_search_field.dart';
import '../widgets/tv_onboarding_step_scaffold.dart';

/// Onboarding accent (gold) — matches the TV start-screen theme.
const Color _kOnboardingAccent = Color(0xFFD4A843);

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

  /// World cities have no official table — show the calculated-times notice and
  /// only commit the selection once the user acknowledges it.
  Future<void> _onWorldCitySelected(
    OnboardingCubit cubit,
    WorldCity city,
  ) async {
    final confirmed = await CalculatedTimesNoticeDialog.show(
      context,
      accent: _kOnboardingAccent,
    );
    if (confirmed != true || !mounted) return;
    await cubit.selectWorldCityAndComplete(city);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<OnboardingCubit>().state;
    final cubit = context.read<OnboardingCubit>();

    return TvOnboardingStepScaffold(
      entrance: widget.entranceAnimation,
      header: Padding(
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
      search: TvOnboardingSearchField(
        controller: _searchController,
        hint: l.settingsSearchCity,
        onChanged: cubit.filterCities,
      ),
      body: Padding(
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
                onSelect: (city) => _onWorldCitySelected(cubit, city),
              ),
      ),
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
