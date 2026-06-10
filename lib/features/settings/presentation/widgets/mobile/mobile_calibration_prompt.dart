import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';

/// Bottom-sheet that asks the user whether to fine-tune the saved
/// times to match a local mosque. Returns `true` when the user wants to
/// calibrate, `false` when they tap Skip or dismiss.
class MobileCalibrationPrompt {
  MobileCalibrationPrompt._();

  static Future<bool> show(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MobileColors.cardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 36,
                color: MobileColors.activePrimary(sheetCtx),
              ),
              const SizedBox(height: 12),
              Text(
                l.settingsCalibrationPromptTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MobileColors.onSurface(sheetCtx),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.settingsCalibrationPromptBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MobileColors.onSurfaceMuted(sheetCtx),
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetCtx).pop(true),
                  child: Text(l.settingsCalibrationPromptYes),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetCtx).pop(false),
                  child: Text(l.settingsCalibrationPromptSkip),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }
}
