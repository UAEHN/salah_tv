import 'package:flutter/material.dart';
import '../../../../../core/calculation_method_info.dart';
import '../../../domain/entities/detected_location.dart';
import '../../../domain/entities/world_city.dart';

/// Typedefs for the two save signatures used by [MobileLocationDialog].
typedef DbSaveCallback = Future<void> Function(String country, String city);
typedef WorldSaveCallback = Future<void> Function(
  String country,
  String city,
  double lat,
  double lng,
  String method, {
  double? utcOffsetHours,
});

/// Stateless helpers that handle city/location selection and dismiss.
///
/// Separated from the dialog StatefulWidget to keep both files under
/// the 150-line limit.
class LocationDialogCallbacks {
  final String? Function() getSelectedCountryKey;
  final DbSaveCallback onSave;
  final WorldSaveCallback? onSaveWorld;
  final BuildContext Function() contextGetter;
  final bool Function() isMounted;

  const LocationDialogCallbacks({
    required this.getSelectedCountryKey,
    required this.onSave,
    this.onSaveWorld,
    required this.contextGetter,
    required this.isMounted,
  });

  Future<void> selectDbCity(String cityKey) async {
    await onSave(getSelectedCountryKey()!, cityKey);
    if (!isMounted()) return;
    Navigator.of(contextGetter()).pop();
  }

  Future<void> selectWorldCity(WorldCity city) async {
    if (onSaveWorld == null) return;
    await onSaveWorld!(
      city.countryArabic, city.arabicName,
      city.latitude, city.longitude, city.calculationMethod,
      utcOffsetHours: city.utcOffset,
    );
    if (!isMounted()) return;
    Navigator.of(contextGetter()).pop();
  }

  Future<void> onLocationDetected(DetectedLocation location) async {
    if (location.isInDb) {
      await onSave(location.dbCountryKey!, location.dbCityKey!);
    } else if (onSaveWorld != null) {
      await onSaveWorld!(
        location.countryName, location.cityName,
        location.latitude, location.longitude,
        defaultMethodForCountryIso(location.isoCountryCode),
      );
    }
    if (!isMounted()) return;
    Navigator.of(contextGetter()).pop();
  }
}
