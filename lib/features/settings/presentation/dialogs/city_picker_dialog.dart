import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/city_translations.dart';

class CityPickerDialog extends StatelessWidget {
  final AccentPalette palette;
  final String selectedCity;
  final List<String> cities;
  final ValueChanged<String> onSelected;

  const CityPickerDialog({
    required this.palette,
    required this.selectedCity,
    required this.cities,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          height: 540,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: palette.primary, size: 26),
                  const SizedBox(width: 12),
                  Text(
                    'اختر المدينة',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),
              Expanded(
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, i) {
                    final city = cities[i];
                    final isSelected = city == selectedCity;
                    return ListTile(
                      leading: Icon(Icons.location_city_rounded,
                          color: isSelected ? palette.primary : Colors.white38),
                      title: Text(
                        cityLabel(city),
                        style: TextStyle(
                          color: isSelected ? palette.primary : Colors.white,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: palette.primary)
                          : null,
                      onTap: () {
                        onSelected(city);
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
