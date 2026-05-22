import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../injection.dart';
import '../../../domain/entities/detected_location.dart';
import '../../../domain/i_location_detector.dart';
import '../../../domain/usecases/detect_location_usecase.dart';

/// Inline "detect my location" pill used inside the location bottom sheet.
/// Compact (no helper text below) because the sheet already explains the
/// flow via title + search field.
class MobileDetectLocationButton extends StatefulWidget {
  final Future<void> Function(DetectedLocation location) onDetected;

  const MobileDetectLocationButton({super.key, required this.onDetected});

  @override
  State<MobileDetectLocationButton> createState() =>
      _MobileDetectLocationButtonState();
}

class _MobileDetectLocationButtonState
    extends State<MobileDetectLocationButton> {
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
    final accent = MobileColors.activePrimary(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton.icon(
          onPressed: _isLoading ? null : _detect,
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                )
              : Icon(Icons.my_location_rounded, size: 18, color: accent),
          label: Text(
            _isLoading
                ? l.settingsDetectingLocation
                : l.settingsDetectMyLocation,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: accent.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: accent.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
