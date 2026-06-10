import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/city_translations.dart';
import '../../../settings/domain/entities/detected_location.dart';

const _accent = Color(0xFFE6B450);

/// Confirmation card shown after GPS auto-detect on the unified onboarding
/// location page. The user sees "Are you in Dubai, UAE?" and either commits
/// ([onConfirm]) or dismisses ([onChange]) to fall back to manual search.
class OnboardingLocationConfirmationCard extends StatelessWidget {
  final DetectedLocation location;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onChange;

  const OnboardingLocationConfirmationCard({
    super.key,
    required this.location,
    required this.isLoading,
    required this.onConfirm,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = l.localeName;
    final cityDisplay = _cityDisplay(locale);
    final countryDisplay = _countryDisplay(locale);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: _accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  l.onboardingConfirmLocationTitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              cityDisplay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            if (countryDisplay.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                countryDisplay,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ConfirmButton(isLoading: isLoading, onTap: onConfirm),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ChangeButton(onTap: isLoading ? null : onChange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _cityDisplay(String locale) {
    final key = location.dbCityKey ?? location.cityName;
    final translated = cityLabel(key, locale: locale);
    return translated.isNotEmpty ? translated : key;
  }

  String _countryDisplay(String locale) {
    final dbKey = location.dbCountryKey;
    if (dbKey != null) return countryLabel(dbKey, locale: locale);
    return location.countryName;
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _ConfirmButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          disabledBackgroundColor: _accent.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1A1208),
                ),
              )
            : Text(
                l.onboardingConfirmAction,
                style: const TextStyle(
                  color: Color(0xFF1A1208),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _ChangeButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ChangeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          l.onboardingChangeAction,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
