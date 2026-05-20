import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/error/failures.dart';
import '../domain/entities/theme_palette_info.dart';
import '../domain/i_theme_catalog_repository.dart';
import 'mobile_theme_palettes.dart';

/// Maps every palette key to its localization label key.
const Map<String, String> _kThemeLabelKeys = {
  // Legacy (TV-shared) — labels already exist in app_*.arb.
  'green': 'themeGreen',
  'teal': 'themeTeal',
  'gold': 'themeGold',
  'blue': 'themeBlue',
  'purple': 'themePurple',
  // Mobile-only extras.
  'desert_dawn': 'themeCoral',
  'paradise_sea': 'themeAzure',
};

class ThemeCatalogRepositoryImpl implements IThemeCatalogRepository {
  const ThemeCatalogRepositoryImpl();

  @override
  Future<Either<Failure, List<ThemePaletteInfo>>> getAll() async {
    try {
      final out = <ThemePaletteInfo>[];
      // Legacy first, in the original insertion order kept by `kThemePalettes`.
      kThemePalettes.forEach((key, palette) {
        out.add(_mapPalette(key, palette, isLegacy: true));
      });
      // Then mobile-only extras — preserve `kMobileExtraPalettes` order.
      kMobileExtraPalettes.forEach((key, palette) {
        out.add(_mapPalette(key, palette, isLegacy: false));
      });
      if (out.isEmpty) {
        return const Left(CacheFailure('empty theme catalog'));
      }
      return Right(out);
    } on Object catch (e) {
      return Left(CacheFailure('theme catalog error: $e'));
    }
  }

  ThemePaletteInfo _mapPalette(
    String key,
    AccentPalette palette, {
    required bool isLegacy,
  }) {
    return ThemePaletteInfo(
      id: key,
      labelKey: _kThemeLabelKeys[key] ?? key,
      primaryArgb: _argb(palette.primary),
      secondaryArgb: _argb(palette.secondary),
      isLegacy: isLegacy,
    );
  }

  // Color → 0xAARRGGBB int. Avoids relying on the deprecated `.value`.
  int _argb(Color c) {
    final a = (c.a * 255.0).round() & 0xFF;
    final r = (c.r * 255.0).round() & 0xFF;
    final g = (c.g * 255.0).round() & 0xFF;
    final b = (c.b * 255.0).round() & 0xFF;
    return (a << 24) | (r << 16) | (g << 8) | b;
  }
}
