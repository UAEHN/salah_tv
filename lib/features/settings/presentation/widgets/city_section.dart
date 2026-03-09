import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';
import '../settings_provider.dart';
import '../dialogs/city_picker_dialog.dart';
import 'tv_button.dart';

class CitySection extends StatelessWidget {
  const CitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final hasCity = settings.selectedCity.isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: tc.glass(opacity: 0.06, borderRadius: 10),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: hasCity ? palette.primary : tc.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasCity ? cityLabel(settings.selectedCity) : 'لم يتم اختيار مدينة',
                    style: TextStyle(
                      fontSize: 18,
                      color: hasCity ? tc.textPrimary : tc.textMuted,
                      fontWeight: hasCity ? FontWeight.w600 : FontWeight.normal,
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
              const Icon(Icons.location_city_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'تغيير المدينة',
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
    final filtered = citiesForCountry(
      settingsProv.settings.selectedCountry,
      settingsProv.availableCities,
    );
    showDialog<void>(
      context: context,
      builder: (_) => CityPickerDialog(
        palette: palette,
        selectedCity: settingsProv.settings.selectedCity,
        cities: filtered,
        onSelected: (city) => settingsProv.updateSelectedCity(city),
      ),
    );
  }
}
