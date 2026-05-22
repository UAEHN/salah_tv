import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/calculation_method_info.dart';
import '../../../../../core/country_name_resolver.dart';
import '../../../../../core/mobile_theme.dart';
import 'mobile_calculation_method_dialog.dart';
import 'mobile_settings_tile.dart';

/// Settings tile for the "calculation method" row.
///
/// For bundled-DB countries (UAE, Egypt, Saudi…) the prayer times come
/// from an official downloaded schedule, so the calculation method is
/// purely informational. We show the natural method for that country
/// plus a small explanatory note, and skip opening the picker because
/// changing it would have no real effect.
///
/// For all other countries (calculated mode) the tile behaves as a normal
/// editable setting that opens the methods picker.
class MobileCalculationMethodTile extends StatelessWidget {
  final String selectedCountryKey;
  final String selectedMethod;
  final bool isCalculatedLocation;
  final ValueChanged<String> onMethodSaved;

  const MobileCalculationMethodTile({
    super.key,
    required this.selectedCountryKey,
    required this.selectedMethod,
    required this.isCalculatedLocation,
    required this.onMethodSaved,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (isCalculatedLocation) {
      return MobileSettingsTile(
        icon: Icons.functions_rounded,
        title: l.settingsCalculationMethodLabel,
        subtitle: localizedCalculationMethod(context, selectedMethod),
        onTap: () => _openPicker(context),
      );
    }
    final displayedMethod = _methodForBundledCountry();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileSettingsTile(
          icon: Icons.functions_rounded,
          title: l.settingsCalculationMethodLabel,
          subtitle: localizedCalculationMethod(context, displayedMethod),
          onTap: () {}, // intentionally inert — see note below
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: MobileColors.onSurfaceMuted(context),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.calculationMethodOfficialScheduleNote,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: MobileColors.onSurfaceMuted(context),
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// What method does this DB-backed country naturally publish?
  /// Falls back to the user's stored method if the reverse lookup misses
  /// (e.g. legacy DB key not present in the ISO map yet).
  String _methodForBundledCountry() {
    final iso = isoForDbCountryKey(selectedCountryKey);
    if (iso == null) return selectedMethod;
    return defaultMethodForCountryIso(iso);
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MobileCalculationMethodDialog(
        currentMethod: selectedMethod,
        onSave: onMethodSaved,
      ),
    );
  }
}
