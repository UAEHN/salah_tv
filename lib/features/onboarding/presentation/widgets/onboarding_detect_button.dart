import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../injection.dart';
import '../../../settings/domain/entities/detected_location.dart';
import '../../../settings/domain/i_location_detector.dart';
import '../../../settings/domain/usecases/detect_location_usecase.dart';

const _accent = Color(0xFFE6B450);

/// Dark-themed "detect my location" button for the onboarding country
/// step. Independent of the app theme so it always reads cleanly on the
/// dark onboarding background.
class OnboardingDetectButton extends StatefulWidget {
  final Future<void> Function(DetectedLocation location) onDetected;

  const OnboardingDetectButton({super.key, required this.onDetected});

  @override
  State<OnboardingDetectButton> createState() => _OnboardingDetectButtonState();
}

class _OnboardingDetectButtonState extends State<OnboardingDetectButton> {
  bool _isLoading = false;

  Future<void> _detect() async {
    setState(() => _isLoading = true);
    final useCase = DetectLocationUseCase(getIt<ILocationDetector>());
    final result = await useCase();
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message, textAlign: TextAlign.center),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (location) async => widget.onDetected(location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: TextButton.icon(
          onPressed: _isLoading ? null : _detect,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _accent,
                  ),
                )
              : const Icon(Icons.my_location_rounded, size: 18, color: _accent),
          label: Text(
            _isLoading
                ? l.settingsDetectingLocation
                : l.settingsDetectMyLocation,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: _accent,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: _accent.withValues(alpha: 0.07),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: _accent.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
