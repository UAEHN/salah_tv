import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../settings_provider.dart';
import '../dialogs/country_picker_dialog.dart';
import 'tv_button.dart';

class CountrySection extends StatelessWidget {
  const CountrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final palette = getThemePalette(settingsProv.settings.themeColorKey);
    final tc = ThemeColors.of(settingsProv.settings.isDarkMode);
    final country = settingsProv.settings.selectedCountry;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: tc.glass(opacity: 0.06, borderRadius: 10),
            child: Row(
              children: [
                Icon(Icons.flag_rounded, color: palette.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    countryLabel(country),
                    style: TextStyle(
                      fontSize: 18,
                      color: tc.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        TvButton(
          onPressed: () => _showPicker(context, settingsProv, palette),
          accent: palette.primary,
          filled: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'تغيير الدولة',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPicker(
    BuildContext context,
    SettingsProvider settingsProv,
    AccentPalette palette,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => CountryPickerDialog(
        palette: palette,
        selectedCountry: settingsProv.settings.selectedCountry,
        countries: kCountries,
        onSelected: (countryKey) async {
          final bloc = context.read<PrayerBloc>();
          await settingsProv.updateSelectedCountry(countryKey);
          final current = bloc.state;
          var filtered = citiesForCountry(countryKey, current.availableCities);
          if (filtered.isEmpty) {
            final state = await bloc.stream
                .firstWhere((s) => s.availableCities.isNotEmpty)
                .timeout(
                  const Duration(seconds: 5),
                  onTimeout: () => bloc.state,
                );
            filtered = citiesForCountry(countryKey, state.availableCities);
          }
          if (filtered.isNotEmpty &&
              !filtered.contains(settingsProv.settings.selectedCity)) {
            settingsProv.updateSelectedCity(filtered.first);
          }
        },
      ),
    );
  }
}
