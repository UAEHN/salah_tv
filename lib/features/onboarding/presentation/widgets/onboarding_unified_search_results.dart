import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../settings/domain/entities/online_geocoding_result.dart';
import '../../../settings/presentation/bloc/online_geocoding_cubit.dart';

const _accent = Color(0xFFE6B450);

/// Renders Nominatim search results inside the dark onboarding background.
/// Surfaces all four cubit states (loading / results / empty / error) and
/// shows a friendly prompt when idle.
class OnboardingUnifiedSearchResults extends StatelessWidget {
  final OnlineGeocodingState state;
  final ValueChanged<OnlineGeocodingResult> onSelect;

  const OnboardingUnifiedSearchResults({
    super.key,
    required this.state,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (state.status) {
      case OnlineGeocodingStatus.idle:
        return _CenteredHint(
          icon: Icons.search_rounded,
          text: l.settingsSearchOnlinePrompt,
        );
      case OnlineGeocodingStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: _accent,
              ),
            ),
          ),
        );
      case OnlineGeocodingStatus.empty:
        return _CenteredHint(
          icon: Icons.location_off_rounded,
          text: l.settingsSearchOnlineEmpty,
        );
      case OnlineGeocodingStatus.error:
        return _CenteredHint(
          icon: Icons.wifi_off_rounded,
          text: l.settingsSearchOnlineError,
        );
      case OnlineGeocodingStatus.results:
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: state.results.length,
          itemBuilder: (_, i) => _ResultTile(
            result: state.results[i],
            onTap: () => onSelect(state.results[i]),
          ),
        );
    }
  }
}

class _CenteredHint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CenteredHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.30), size: 36),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final OnlineGeocodingResult result;
  final VoidCallback onTap;
  const _ResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final country = result.countryName ?? result.countryCode;
    final admin = result.administrativeArea;
    final subtitle = (admin != null && admin.isNotEmpty && admin != result.name)
        ? '$admin — $country'
        : country;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              color: Colors.white.withValues(alpha: 0.03),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_city_rounded,
                  color: _accent.withValues(alpha: 0.85),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        result.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
