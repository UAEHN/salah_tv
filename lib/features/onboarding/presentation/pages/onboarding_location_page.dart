import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../injection.dart';
import '../../../settings/data/online_result_to_detected_location.dart';
import '../../../settings/domain/entities/online_geocoding_result.dart';
import '../../../settings/domain/i_location_detector.dart';
import '../../../settings/domain/i_online_geocoding_repository.dart';
import '../../../settings/domain/usecases/detect_location_usecase.dart';
import '../../../settings/presentation/bloc/online_geocoding_cubit.dart';
import '../onboarding_cubit.dart';
import '../widgets/onboarding_detect_button.dart';
import '../widgets/onboarding_location_confirmation_card.dart';
import '../widgets/onboarding_page_header.dart';
import '../widgets/onboarding_search_field.dart';
import '../widgets/onboarding_unified_search_results.dart';

/// Unified onboarding location screen: GPS button + Nominatim search +
/// confirmation card after GPS auto-detect. Replaces the previous two-step
/// country → city flow on mobile.
class OnboardingLocationPage extends StatefulWidget {
  final Animation<double> entranceAnimation;

  const OnboardingLocationPage({super.key, required this.entranceAnimation});

  @override
  State<OnboardingLocationPage> createState() => _OnboardingLocationPageState();
}

class _OnboardingLocationPageState extends State<OnboardingLocationPage> {
  late final TextEditingController _searchController;
  late final OnlineGeocodingCubit _onlineCubit;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _onlineCubit = OnlineGeocodingCubit(getIt<IOnlineGeocodingRepository>());
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoDetect());
  }

  /// Auto-runs GPS detection only when the user has already granted permission
  /// in a prior session — never prompts here. First-time users still tap the
  /// explicit detect button before any system permission dialog appears.
  Future<void> _maybeAutoDetect() async {
    if (!mounted) return;
    final cubit = context.read<OnboardingCubit>();
    final locale = AppLocalizations.of(context).localeName;

    final permission = await Geolocator.checkPermission();
    if (!mounted) return;
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return;
    }
    if (cubit.state.pendingConfirmation != null) return;
    if (_searchController.text.isNotEmpty) return;

    final useCase = DetectLocationUseCase(getIt<ILocationDetector>());
    final result = await useCase(locale: locale);
    if (!mounted) return;
    if (cubit.state.pendingConfirmation != null) return;
    if (_searchController.text.isNotEmpty) return;
    result.fold(
      (_) {}, // silent — user can still use the button or search
      (location) => cubit.setPendingConfirmation(location),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _onlineCubit.close();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {}); // refresh suffixIcon visibility
    _onlineCubit.searchDebounced(query);
  }

  void _onClearQuery() {
    _searchController.clear();
    _onlineCubit.clear();
    setState(() {});
  }

  Future<void> _onSelectOnline(OnlineGeocodingResult r) async {
    final cubit = context.read<OnboardingCubit>();
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
    final cubitState = context.watch<OnboardingCubit>().state;
    final hasPending = cubitState.pendingConfirmation != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingPageHeader(
          title: l.onboardingLocationTitle,
          subtitle: l.onboardingLocationSubtitle,
        ),
        const SizedBox(height: 8),
        if (hasPending)
          OnboardingLocationConfirmationCard(
            location: cubitState.pendingConfirmation!,
            isLoading: cubitState.isLoading,
            onConfirm: () => context.read<OnboardingCubit>().confirmPending(),
            onChange: () => context.read<OnboardingCubit>().rejectPending(),
          )
        else ...[
          OnboardingDetectButton(
            onDetected: (loc) async {
              if (!mounted) return;
              context.read<OnboardingCubit>().setPendingConfirmation(loc);
            },
          ),
          _OrDivider(label: l.onboardingOrSearchManually),
          OnboardingSearchField(
            controller: _searchController,
            hintText: l.settingsSearchOnlineHint,
            onChanged: _onQueryChanged,
            onClear: _onClearQuery,
          ),
        ],
        Expanded(
          child: hasPending
              ? const SizedBox.shrink()
              : BlocBuilder<OnlineGeocodingCubit, OnlineGeocodingState>(
                  bloc: _onlineCubit,
                  builder: (_, state) => OnboardingUnifiedSearchResults(
                    state: state,
                    onSelect: _onSelectOnline,
                  ),
                ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  final String label;
  const _OrDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.white.withValues(alpha: 0.10),
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.white.withValues(alpha: 0.10),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
