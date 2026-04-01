import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../injection.dart';
import '../../../domain/entities/detected_location.dart';
import '../../../domain/i_location_detector.dart';
import '../../../domain/usecases/detect_location_usecase.dart';

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
      (location) async {
        await widget.onDetected(location);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _detect,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location_rounded, size: 20),
          label: Text(
            _isLoading
                ? l.settingsDetectingLocation
                : l.settingsDetectMyLocation,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal',
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: MobileColors.primary.withValues(alpha: 0.12),
            foregroundColor: MobileColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: MobileColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
