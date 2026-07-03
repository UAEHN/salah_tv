import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import 'tv_button.dart';

/// Elegant, TV-readable notice shown the moment the user picks a city that is
/// NOT in the official prayer-time tables (i.e. an astronomically *calculated*
/// location — `isCalculatedLocation == true`). It explains, without technical
/// jargon, that the times are computed and may differ slightly from the
/// country's official schedule.
///
/// Surfaced at two points: first-run onboarding (TV start screen) and when the
/// user changes country/city from settings. Returns `true` when the user
/// acknowledges via the action button, `null` when dismissed (remote BACK).
class CalculatedTimesNoticeDialog extends StatelessWidget {
  final Color accent;
  const CalculatedTimesNoticeDialog._({required this.accent});

  static Future<bool?> show(BuildContext context, {required Color accent}) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (_) => CalculatedTimesNoticeDialog._(accent: accent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(40),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            padding: const EdgeInsets.fromLTRB(40, 36, 40, 28),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accent.withValues(alpha: 0.9),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.16),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(Icons.public_rounded, color: accent, size: 40),
                ),
                const SizedBox(height: 22),
                Text(
                  l.calculatedTimesNoticeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l.calculatedTimesNoticeBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 30),
                TvButton(
                  accent: accent,
                  filled: true,
                  autofocus: true,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    l.calculatedTimesNoticeAction,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
