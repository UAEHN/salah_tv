import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/remote_city_result.dart';
import '../../../domain/entities/world_city.dart';
import '../../logic/location_picker_logic.dart';
import '../../logic/merged_city_results.dart';
import 'mobile_location_empty_state.dart';
import 'mobile_location_option_tile.dart';
import 'mobile_location_remote_city_tile.dart';

/// Top-level results list shown when a search query is active and no
/// country has been drilled into. Combines matching cities (local +
/// remote) with the existing country-name matches in one scroll.
class MobileLocationMixedResultsList extends StatelessWidget {
  final List<UnifiedCountry> countries;
  final List<MergedCityRow> cityRows;
  final bool remoteLoading;
  final String currentCountry;
  final ValueChanged<String> onSelectCountry;
  final ValueChanged<WorldCity> onSelectLocalCity;
  final ValueChanged<RemoteCityResult> onSelectRemoteCity;

  const MobileLocationMixedResultsList({
    super.key,
    required this.countries,
    required this.cityRows,
    required this.remoteLoading,
    required this.currentCountry,
    required this.onSelectCountry,
    required this.onSelectLocalCity,
    required this.onSelectRemoteCity,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasCities = cityRows.isNotEmpty;
    final hasCountries = countries.isNotEmpty;
    if (!hasCities && !hasCountries && !remoteLoading) {
      return MobileLocationEmptyState(message: l.settingsNoMatchingCountries);
    }
    final isEn = l.localeName == 'en';
    return ListView(
      key: const ValueKey('mixed_results'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (hasCities) ...[
          const _SectionHeader(label: 'المدن'),
          ...cityRows.map((row) => _rowFor(context, l, row)),
          const SizedBox(height: 8),
        ],
        if (remoteLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        if (hasCountries) ...[
          const _SectionHeader(label: 'الدول'),
          ...countries.map(
            (c) => MobileLocationOptionTile(
              title: isEn ? c.englishName : c.arabicName,
              subtitle: isEn ? c.arabicName : c.englishName,
              isSelected: c.key == currentCountry,
              onTap: () => onSelectCountry(c.key),
            ),
          ),
        ],
      ],
    );
  }

  Widget _rowFor(BuildContext context, AppLocalizations l, MergedCityRow row) {
    if (row is LocalCityRow) {
      final c = row.city;
      return MobileLocationOptionTile(
        title: cityLabel(
          c.name,
          locale: l.localeName,
          countryKey: c.countryKey,
        ),
        subtitle: c.countryArabic,
        isSelected: false,
        onTap: () => onSelectLocalCity(c),
      );
    }
    if (row is RemoteCityRow) {
      return MobileLocationRemoteCityTile(
        result: row.result,
        onTap: () => onSelectRemoteCity(row.result),
      );
    }
    return const SizedBox.shrink();
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
    child: Text(
      label,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        color: MobileColors.onSurfaceMuted(context),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),
  );
}
