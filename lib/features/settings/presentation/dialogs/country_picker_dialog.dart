import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';

class CountryPickerDialog extends StatelessWidget {
  final AccentPalette palette;
  final String selectedCountry;
  final List<CountryInfo> countries;
  final ValueChanged<String> onSelected;

  const CountryPickerDialog({
    required this.palette,
    required this.selectedCountry,
    required this.countries,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEn = l.localeName == 'en';
    return Directionality(
      textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.public_rounded, color: palette.primary, size: 26),
                  const SizedBox(width: 12),
                  Text(
                    l.settingsSelectCountry,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: countries.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, i) {
                    final c = countries[i];
                    final isSelected = c.key == selectedCountry;
                    return ListTile(
                      leading: Icon(
                        Icons.flag_rounded,
                        color: isSelected ? palette.primary : Colors.white38,
                      ),
                      title: Text(
                        isEn ? c.englishName : c.arabicName,
                        style: TextStyle(
                          color: isSelected ? palette.primary : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: palette.primary)
                          : null,
                      onTap: () {
                        onSelected(c.key);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
