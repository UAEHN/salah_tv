import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';
import '../../../../features/prayer/data/composite_prayer_repository.dart';
import '../../../../features/prayer/domain/usecases/download_city_use_case.dart';
import '../../../../injection.dart';
import '../../domain/i_world_city_repository.dart';
import '../bloc/location_selection_cubit.dart';
import '../bloc/tv_location_picker_cubit.dart';
import '../settings_provider.dart';
import 'location_value_card.dart';
import 'tv_location_picker/tv_location_picker_dialog.dart';

class TvLocationSection extends StatelessWidget {
  const TvLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocationValueCard(
          icon: Icons.public_rounded,
          label: l.settingsSelectCountry,
          value: countryLabel(settings.selectedCountry, locale: l.localeName),
          tc: tc,
          accent: palette.primary,
          autofocus: true,
          onPressed: () => _showLocationDialog(context),
        ),
        const SizedBox(height: 16),
        LocationValueCard(
          icon: Icons.location_on_rounded,
          label: l.settingsSelectCity,
          value: cityLabel(
            settings.selectedCity,
            locale: l.localeName,
            countryKey: settings.selectedCountry,
          ),
          tc: tc,
          accent: palette.primary,
          onPressed: () =>
              _showLocationDialog(context, showCitiesForCurrentCountry: true),
        ),
      ],
    );
  }

  void _showLocationDialog(
    BuildContext context, {
    bool showCitiesForCurrentCountry = false,
  }) {
    final settingsProvider = context.read<SettingsProvider>();
    final settings = settingsProvider.settings;
    showDialog<void>(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => LocationSelectionCubit(
              settingsProvider,
              getIt<DownloadCityUseCase>(),
              getIt<CompositePrayerRepository>(),
            ),
          ),
          BlocProvider(
            create: (_) => TvLocationPickerCubit(
              getIt<IWorldCityRepository>(),
              currentCountry: settings.selectedCountry,
              currentCity: settings.selectedCity,
            )..load(showCitiesForCurrentCountry: showCitiesForCurrentCountry),
          ),
        ],
        child: const TvLocationPickerDialog(),
      ),
    );
  }
}
