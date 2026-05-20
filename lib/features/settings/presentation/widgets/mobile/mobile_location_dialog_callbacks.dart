import 'package:flutter/material.dart';
import '../../../../../core/calculation_method_info.dart';
import '../../../domain/entities/detected_location.dart';
import '../../../domain/entities/world_city.dart';

/// Typedefs for the two save signatures used by [MobileLocationDialog].
/// Both return `true` when the persist+download chain succeeds, `false` if
/// the dialog should remain open (e.g. download failure).
typedef DbSaveCallback = Future<bool> Function(String country, String city);
typedef WorldSaveCallback =
    Future<bool> Function(
      String country,
      String city,
      double lat,
      double lng,
      String method, {
      String? timeZoneId,
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
    final ok = await onSave(getSelectedCountryKey()!, cityKey);
    if (!isMounted() || !ok) return;
    Navigator.of(contextGetter()).pop();
  }

  Future<void> selectWorldCity(WorldCity city) async {
    if (onSaveWorld == null) return;
    final ok = await onSaveWorld!(
      city.countryKey,
      city.name,
      city.latitude,
      city.longitude,
      city.calculationMethod,
      timeZoneId: city.timeZoneId,
      utcOffsetHours: city.utcOffset,
    );
    if (!isMounted() || !ok) return;
    Navigator.of(contextGetter()).pop();
  }

  Future<void> onLocationDetected(DetectedLocation location) async {
    bool ok = false;
    if (location.isInDb) {
      ok = await onSave(location.dbCountryKey!, location.dbCityKey!);
    } else if (onSaveWorld != null) {
      ok = await onSaveWorld!(
        location.isoCountryCode ?? location.countryName,
        location.cityName,
        location.latitude,
        location.longitude,
        location.calculationMethod ??
            defaultMethodForCountryIso(location.isoCountryCode),
        timeZoneId: location.timeZoneId,
        utcOffsetHours: location.utcOffsetHours,
      );
    }
    if (!isMounted() || !ok) return;
    Navigator.of(contextGetter()).pop();
  }
}
