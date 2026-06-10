import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../logic/calculation_method_suggester.dart';
import '../settings_provider.dart';
import '../widgets/tv_location_picker/tv_high_latitude_banner.dart';
import '../widgets/tv_location_picker/tv_method_preview_card.dart';

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

/// TV-friendly variant of the method picker. Full-screen, D-pad
/// navigable, autofocuses the suggested card so a single Select press
/// commits the recommended option. Pops with the chosen method key.
class TvCalculationMethodPickerScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? isoCountryCode;
  final String cityName;

  const TvCalculationMethodPickerScreen({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.isoCountryCode,
    super.key,
  });

  /// Pushes a route that keeps [SettingsProvider] in scope (the prior
  /// online-search page already disposed its own geocoding cubit before
  /// returning the picked result, so nothing else is needed here).
  static Future<String?> push(
    BuildContext context, {
    required double latitude,
    required double longitude,
    required String cityName,
    String? isoCountryCode,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => TvCalculationMethodPickerScreen(
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
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final suggestion = suggestMethodForLocation(
      isoCountryCode: isoCountryCode,
      latitude: latitude,
    );
    final alternatives = _allMethods
        .where((m) => m != suggestion.method)
        .toList(growable: false);
    return Scaffold(
      backgroundColor: tc.bgSurface,
      appBar: AppBar(
        backgroundColor: tc.bgSurface,
        title: Text(
          l.settingsPickCalculationMethod,
          style: TextStyle(color: tc.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: tc.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(40, 12, 40, 40),
        children: [
          _cityHeader(tc),
          TvHighLatitudeBanner(
            band: suggestion.band,
            highMessage: l.settingsHighLatitudeMessage,
            extremeMessage: l.settingsExtremeLatitudeMessage,
          ),
          _sectionLabel(tc, l.settingsSuggestedForLocation),
          TvMethodPreviewCard(
            methodKey: suggestion.method,
            latitude: latitude,
            longitude: longitude,
            highLatitudeRuleKey: suggestion.highLatitudeRule,
            isSuggested: true,
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(suggestion.method),
          ),
          const SizedBox(height: 14),
          _sectionLabel(tc, l.settingsOtherMethods),
          for (final method in alternatives)
            TvMethodPreviewCard(
              methodKey: method,
              latitude: latitude,
              longitude: longitude,
              highLatitudeRuleKey: suggestion.highLatitudeRule,
              onPressed: () => Navigator.of(context).pop(method),
            ),
        ],
      ),
    );
  }

  Widget _cityHeader(ThemeColors tc) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 14),
    child: Row(
      children: [
        Icon(Icons.location_on_outlined, color: tc.textMuted, size: 24),
        const SizedBox(width: 10),
        Text(
          cityName,
          style: TextStyle(
            color: tc.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _sectionLabel(ThemeColors tc, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
    child: Text(
      text,
      style: TextStyle(
        color: tc.textMuted,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),
  );
}
