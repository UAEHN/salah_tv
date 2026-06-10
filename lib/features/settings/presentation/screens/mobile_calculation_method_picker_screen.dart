import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/mobile_theme.dart';
import '../logic/calculation_method_suggester.dart';
import '../settings_provider.dart';
import '../widgets/mobile/mobile_high_latitude_banner.dart';
import '../widgets/mobile/mobile_method_picker_chrome.dart';
import '../widgets/mobile/mobile_method_preview_card.dart';

/// Order matters: the smart suggestion is rendered first separately, then
/// these run as the long list. Worldwide-friendly defaults come before
/// region-specific entries so users scrolling top-to-bottom see common
/// options early.
const _allMethods = <String>[
  'muslim_world_league',
  'egyptian',
  'karachi',
  'north_america',
  'umm_al_qura',
  'dubai',
  'qatar',
  'kuwait',
  'turkiye',
  'tehran',
  'morocco',
  'singapore',
  'moonsighting_committee',
  'france',
  'uoif',
  'uk',
  'germany',
  'russia',
  'jafari',
];

/// Lets the user pick the calculation method for a worldwide-online city.
/// Shows the smart suggestion prominently and every alternative with a
/// live preview of today's five times — the user matches the method
/// whose schedule looks like their local mosque.
class MobileCalculationMethodPickerScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? isoCountryCode;
  final String cityName;

  const MobileCalculationMethodPickerScreen({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.isoCountryCode,
    super.key,
  });

  static Future<String?> push(
    BuildContext context, {
    required double latitude,
    required double longitude,
    required String cityName,
    String? isoCountryCode,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => MobileCalculationMethodPickerScreen(
          latitude: latitude,
          longitude: longitude,
          cityName: cityName,
          isoCountryCode: isoCountryCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final use24Hour = context.select<SettingsProvider, bool>(
      (p) => p.settings.use24HourFormat,
    );
    final suggestion = suggestMethodForLocation(
      isoCountryCode: isoCountryCode,
      latitude: latitude,
    );
    final alternatives = _allMethods
        .where((m) => m != suggestion.method)
        .toList(growable: false);
    return Scaffold(
      backgroundColor: MobileColors.background(context),
      appBar: AppBar(
        backgroundColor: MobileColors.background(context),
        title: Text(l.settingsPickCalculationMethod),
        titleTextStyle: TextStyle(
          color: MobileColors.onSurface(context),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: MobileColors.onSurface(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        children: [
          MethodPickerCityHeader(name: cityName),
          MobileHighLatitudeBanner(
            band: suggestion.band,
            highMessage: l.settingsHighLatitudeMessage,
            extremeMessage: l.settingsExtremeLatitudeMessage,
          ),
          MethodPickerSectionLabel(text: l.settingsSuggestedForLocation),
          MobileMethodPreviewCard(
            methodKey: suggestion.method,
            latitude: latitude,
            longitude: longitude,
            highLatitudeRuleKey: suggestion.highLatitudeRule,
            isSuggested: true,
            use24Hour: use24Hour,
            onTap: () => Navigator.of(context).pop(suggestion.method),
          ),
          const SizedBox(height: 12),
          MethodPickerSectionLabel(text: l.settingsOtherMethods),
          for (final method in alternatives)
            MobileMethodPreviewCard(
              methodKey: method,
              latitude: latitude,
              longitude: longitude,
              highLatitudeRuleKey: suggestion.highLatitudeRule,
              use24Hour: use24Hour,
              onTap: () => Navigator.of(context).pop(method),
            ),
        ],
      ),
    );
  }
}
