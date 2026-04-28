import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';
import '../../../../features/prayer/data/composite_prayer_repository.dart';
import '../../../../features/prayer/domain/usecases/download_city_use_case.dart';
import '../../../../features/prayer/presentation/bloc/prayer_bloc.dart';
import '../../../../features/prayer/presentation/bloc/prayer_event.dart';
import '../../../../injection.dart';
import '../../domain/i_world_city_repository.dart';
import '../bloc/location_selection_cubit.dart';
import '../bloc/tv_location_picker_cubit.dart';
import '../settings_provider.dart';
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
        _LocationValueCard(
          icon: Icons.public_rounded,
          label: l.settingsSelectCountry,
          value: countryLabel(settings.selectedCountry, locale: l.localeName),
          tc: tc,
          accent: palette.primary,
          autofocus: true,
          onPressed: () => _showLocationDialog(context),
        ),
        const SizedBox(height: 16),
        _LocationValueCard(
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
              onCityReady: () =>
                  context.read<PrayerBloc>().add(const PrayerReloaded()),
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

class _LocationValueCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeColors tc;
  final Color accent;
  final VoidCallback onPressed;
  final bool autofocus;

  const _LocationValueCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tc,
    required this.accent,
    required this.onPressed,
    this.autofocus = false,
  });

  @override
  State<_LocationValueCard> createState() => _LocationValueCardState();
}

class _LocationValueCardState extends State<_LocationValueCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isFocused;
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (isFocused) => setState(() => _isFocused = isFocused),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: widget.tc
              .glass(opacity: 0.07, borderRadius: 14)
              .copyWith(
                border: Border.all(
                  color: isActive ? Colors.white : Colors.white12,
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: widget.accent.withValues(alpha: 0.28),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.accent, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.tc.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 20,
                        color: widget.tc.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: isActive ? Colors.white : Colors.white38,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
