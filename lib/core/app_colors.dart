import 'package:flutter/material.dart';

// ─── Light theme base colors ────────────────────────────────────────────────
const Color kBgDeep      = Color(0xFFF0F4F8);
const Color kBgDark      = Color(0xFFFFFFFF);
const Color kBgSurface   = Color(0xFFF5F7FA);
const Color kBgGlass     = Color(0x14000000);
const Color kBorderGlass = Color(0x1A000000);
const Color kTextPrimary   = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF4A4A6A);
const Color kTextMuted     = Color(0xFF8A8AA0);

// ─── Dark theme base colors ──────────────────────────────────────────────────
const Color kDarkBgDeep      = Color(0xFF07101E);
const Color kDarkBgMain      = Color(0xFF0C1528);
const Color kDarkBgSurface   = Color(0xFF162035);
const Color kDarkBgGlass     = Color(0x20FFFFFF);
const Color kDarkBorderGlass = Color(0x2AFFFFFF);
const Color kDarkTextPrimary   = Color(0xFFF0F4FF);
const Color kDarkTextSecondary = Color(0xFFB8C0D8);
const Color kDarkTextMuted     = Color(0xFF6A7494);

// ─── ThemeColors – single source of truth for light/dark ────────────────────
class ThemeColors {
  final Color bgDeep;
  final Color bgMain;
  final Color bgSurface;
  final Color bgGlass;
  final Color borderGlass;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final bool isDark;

  const ThemeColors._({
    required this.bgDeep,
    required this.bgMain,
    required this.bgSurface,
    required this.bgGlass,
    required this.borderGlass,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.isDark,
  });

  static const ThemeColors _light = ThemeColors._(
    bgDeep: kBgDeep, bgMain: kBgDark, bgSurface: kBgSurface,
    bgGlass: kBgGlass, borderGlass: kBorderGlass,
    textPrimary: kTextPrimary, textSecondary: kTextSecondary,
    textMuted: kTextMuted, isDark: false,
  );

  static const ThemeColors _dark = ThemeColors._(
    bgDeep: kDarkBgDeep, bgMain: kDarkBgMain, bgSurface: kDarkBgSurface,
    bgGlass: kDarkBgGlass, borderGlass: kDarkBorderGlass,
    textPrimary: kDarkTextPrimary, textSecondary: kDarkTextSecondary,
    textMuted: kDarkTextMuted, isDark: true,
  );

  static ThemeColors of(bool isDark) => isDark ? _dark : _light;

  LinearGradient get bgGradient => LinearGradient(
    colors: [bgDeep, bgMain],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  BoxDecoration glass({
    double opacity = 0.08,
    double borderRadius = 16,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: (isDark ? Colors.white : Colors.black)
          .withValues(alpha: opacity * (isDark ? 0.65 : 0.5)),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderGlass, width: 1),
      boxShadow: glowColor != null
          ? [BoxShadow(
              color: glowColor.withValues(alpha: 0.15),
              blurRadius: 20, spreadRadius: 2)]
          : null,
    );
  }
}

// ─── Theme accent palettes ───────────────────────────────────────────────────
class AccentPalette {
  final Color primary;
  final Color secondary;
  final Color glow;

  const AccentPalette({
    required this.primary,
    required this.secondary,
    required this.glow,
  });

  LinearGradient get gradient => LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get horizontalGradient => LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
}

const Map<String, AccentPalette> kThemePalettes = {
  'green': AccentPalette(
    primary:   Color(0xFF10B981),
    secondary: Color(0xFF059669),
    glow:      Color(0x4010B981),
  ),
  'teal': AccentPalette(
    primary:   Color(0xFF14B8A6),
    secondary: Color(0xFF0D9488),
    glow:      Color(0x4014B8A6),
  ),
  'gold': AccentPalette(
    primary:   Color(0xFFF59E0B),
    secondary: Color(0xFFD97706),
    glow:      Color(0x40F59E0B),
  ),
  'blue': AccentPalette(
    primary:   Color(0xFF2980B9),
    secondary: Color(0xFF1A6B9C),
    glow:      Color(0x402980B9),
  ),
  'purple': AccentPalette(
    primary:   Color(0xFF7C3AED),
    secondary: Color(0xFF6D28D9),
    glow:      Color(0x407C3AED),
  ),
};

const Map<String, String> kThemeLabels = {
  'green': 'زمردي',
  'teal':  'فيروزي',
  'gold':  'ذهبي',
  'blue':  'ياقوتي',
  'purple': 'بنفسجي',
};

Color getThemeColor(String key) =>
    kThemePalettes[key]?.primary ?? kThemePalettes['green']!.primary;

AccentPalette getThemePalette(String key) =>
    kThemePalettes[key] ?? kThemePalettes['green']!;

// ─── Legacy helpers (backward compatibility) ─────────────────────────────────
BoxDecoration glassDecoration({
  double opacity = 0.08,
  double borderRadius = 16,
  Color? glowColor,
}) {
  return BoxDecoration(
    color: Colors.black.withValues(alpha: opacity * 0.5),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: kBorderGlass, width: 1),
    boxShadow: glowColor != null
        ? [BoxShadow(
            color: glowColor.withValues(alpha: 0.15),
            blurRadius: 20, spreadRadius: 2)]
        : null,
  );
}

LinearGradient bgGradient() => const LinearGradient(
      colors: [kBgDeep, kBgDark],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
