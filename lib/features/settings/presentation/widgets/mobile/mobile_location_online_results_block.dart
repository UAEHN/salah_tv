import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/online_geocoding_result.dart';
import '../../bloc/online_geocoding_cubit.dart';
import '../online_city_result_tile.dart';

/// Footer section appended below the local city list when the user is in the
/// city-picker level. Surfaces Nominatim results for towns that are not in
/// the bundled DB or world catalog — solves the «my city isn't on the list»
/// problem after a country has already been chosen.
class MobileLocationOnlineResultsBlock extends StatelessWidget {
  final OnlineGeocodingState state;
  final ValueChanged<OnlineGeocodingResult> onSelect;

  const MobileLocationOnlineResultsBlock({
    super.key,
    required this.state,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final body = _body(context, l);
    if (body == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [_header(context, l), const SizedBox(height: 6), body],
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 4, left: 4),
      child: Text(
        l.settingsSearchOnline,
        style: TextStyle(
          color: MobileColors.onSurfaceMuted(context),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget? _body(BuildContext context, AppLocalizations l) {
    switch (state.status) {
      case OnlineGeocodingStatus.idle:
        return null;
      case OnlineGeocodingStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
        );
      case OnlineGeocodingStatus.error:
        return _hint(context, l.settingsSearchOnlineError);
      case OnlineGeocodingStatus.empty:
        return _hint(context, l.settingsSearchOnlineEmpty);
      case OnlineGeocodingStatus.results:
        final tc = ThemeColors.of(
          Theme.of(context).brightness == Brightness.dark,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in state.results)
              OnlineCityResultTile(result: r, tc: tc, onTap: () => onSelect(r)),
          ],
        );
    }
  }

  Widget _hint(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        message,
        style: TextStyle(
          color: MobileColors.onSurfaceMuted(context),
          fontSize: 13,
        ),
      ),
    );
  }
}
