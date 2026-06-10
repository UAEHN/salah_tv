import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_colors.dart';
import '../../settings_provider.dart';

/// TV-skinned modal dialog asking whether to fine-tune the saved times.
/// Returns `true` when the user confirms calibration, `false` for skip.
/// The "Yes" button autofocuses so a single Select press accepts.
class TvCalibrationPrompt {
  TvCalibrationPrompt._();

  static Future<bool> show(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final settings = context.read<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final accent = getThemePalette(settings.themeColorKey).primary;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: tc.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: accent.withValues(alpha: 0.20)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 44, color: accent),
                const SizedBox(height: 16),
                Text(
                  l.settingsCalibrationPromptTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tc.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.settingsCalibrationPromptBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tc.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: Text(l.settingsCalibrationPromptYes),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    l.settingsCalibrationPromptSkip,
                    style: TextStyle(color: tc.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }
}
