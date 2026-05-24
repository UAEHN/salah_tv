import 'package:flutter/material.dart';
import '../../../../../core/calculation_method_info.dart';
import '../../../domain/entities/detected_location.dart';
import '../../../domain/entities/remote_city_result.dart';
import '../../../domain/entities/world_city.dart';
import '../../../domain/usecases/resolve_calculation_method_for_iso_usecase.dart';
import '../../../domain/usecases/resolve_timezone_for_coords_usecase.dart';

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
  final ResolveCalculationMethodForIsoUseCase resolveMethod;
  final ResolveTimezoneForCoordsUseCase resolveTimezone;

  const LocationDialogCallbacks({
    required this.getSelectedCountryKey,
    required this.onSave,
    this.onSaveWorld,
    required this.contextGetter,
    required this.isMounted,
    required this.resolveMethod,
    required this.resolveTimezone,
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
      _resolveMethodForCity(city),
      timeZoneId: city.timeZoneId,
      utcOffsetHours: city.utcOffset,
    );
    if (!isMounted() || !ok) return;
    Navigator.of(contextGetter()).pop();
  }

  // Defense in depth: if the city carries the generic fallback method but
  // its country has a specific default (e.g. FR → Mosquée de Paris), use
  // the country default. Keeps behavior correct even for stale JSON rows.
  String _resolveMethodForCity(WorldCity city) {
    if (city.calculationMethod != 'muslim_world_league') {
      return city.calculationMethod;
    }
    final byCountry = defaultMethodForCountryIso(city.countryKey);
    return byCountry == 'muslim_world_league'
        ? city.calculationMethod
        : byCountry;
  }

  Future<void> selectRemoteCity(RemoteCityResult r) async {
    if (onSaveWorld == null) return;
    final ok = await onSaveWorld!(
      r.countryCode,
      r.preferredLabel,
      r.latitude,
      r.longitude,
      resolveMethod(r.countryCode),
      timeZoneId: resolveTimezone(r.latitude, r.longitude),
      utcOffsetHours: null,
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
