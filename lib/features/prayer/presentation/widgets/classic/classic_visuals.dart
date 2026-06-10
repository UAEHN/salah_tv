import 'package:flutter/material.dart';

import 'package:ghasaq/core/app_colors.dart';

/// Derived visual tokens for the classic TV home ("mosque display") design.
///
/// Brightness-aware: dark mode → deep navy/gold; light mode → a cool light
/// palette. The accent (gold) follows the selected theme colour via
/// [AccentPalette]; surfaces/text/dividers come from [ThemeColors].
///
/// One source of truth for every classic widget — keeps colours out of the
/// widget bodies (§10 theming, §4 DRY).
class ClassicVisuals {
  final ThemeColors tc;
  final AccentPalette palette;

  const ClassicVisuals(this.tc, this.palette);

  /// Background for the whole classic screen. Dark mode → deep navy. Light mode
  /// → a cool light slate that is clearly deeper than the white panels so they
  /// pop (the old warm parchment sat too close to the card colour → washed-out
  /// low contrast).
  LinearGradient get bgGradient => tc.isDark
      ? tc.bgGradient
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
        );

  // ── Accent (gold) ──────────────────────────────────────────────────────
  /// Base accent — design `--gold` (#D4A843 when the gold theme is selected).
  Color get gold => palette.primary;

  /// Emphasised accent for active text / countdown — design `--gold-hi`.
  /// On dark surfaces it brightens toward white so it glows; on light surfaces
  /// brightening would wash it out, so it darkens instead to stay readable.
  Color get goldHi =>
      (tc.isDark
          ? Color.lerp(palette.primary, Colors.white, 0.34)
          : Color.lerp(palette.primary, Colors.black, 0.40)) ??
      palette.primary;

  /// Faint accent wash for active-row / pill fills — design `--gold-soft`.
  Color get goldSoft => palette.primary.withValues(alpha: 0.10);

  LinearGradient get activeRowGradient => LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [palette.primary, palette.secondary],
  );

  Color get onAccent {
    return Colors.white;
  }

  // ── Text ───────────────────────────────────────────────────────────────
  Color get fg => tc.textPrimary; // --fg
  Color get fgSec => tc.textSecondary; // --fg-sec
  Color get fgMuted => tc.textMuted; // --fg-muted
  Color get countdownText => tc.isDark ? Colors.white : const Color(0xFF0F172A);

  // ── Hairlines / surfaces ───────────────────────────────────────────────
  /// Subtle divider — design `--line`.
  Color get line => tc.isDark
      ? Colors.white.withValues(alpha: 0.065)
      : const Color(0xFF34423E).withValues(alpha: 0.12);

  /// Stronger divider — design `--line-strong`.
  Color get lineStrong => tc.isDark
      ? Colors.white.withValues(alpha: 0.11)
      : const Color(0xFF34423E).withValues(alpha: 0.22);

  /// Panel fill — a more solid surface so the prayer list reads as a distinct
  /// card against the navy background (kept opaque, not see-through).
  Color get panelBg => tc.isDark
      ? Color.alphaBlend(Colors.white.withValues(alpha: 0.05), tc.bgMain)
      : const Color(0xFFFCFEFF);

  LinearGradient get countCardGradient => tc.isDark
      ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gold.withValues(alpha: 0.07), gold.withValues(alpha: 0.022)],
        )
      : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
              gold.withValues(alpha: 0.14),
              const Color(0xFFFFFBF1),
            ),
            Color.alphaBlend(
              gold.withValues(alpha: 0.055),
              const Color(0xFFF7FAFB),
            ),
          ],
        );

  Color get countCardBorder => tc.isDark
      ? gold.withValues(alpha: 0.22)
      : Color.alphaBlend(gold.withValues(alpha: 0.42), const Color(0xFF8F9A94));

  List<BoxShadow> get panelShadow => tc.isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ]
      : [
          BoxShadow(
            color: const Color(0xFF23312D).withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.45),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ];

  List<BoxShadow> get countCardShadow => tc.isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ]
      : [
          BoxShadow(
            color: const Color(0xFF23312D).withValues(alpha: 0.20),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: gold.withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ];
}
