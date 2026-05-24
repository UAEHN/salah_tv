import 'dart:math' as math;

import '../../domain/entities/remote_city_result.dart';
import '../../domain/entities/world_city.dart';

sealed class MergedCityRow {
  const MergedCityRow();
}

class LocalCityRow extends MergedCityRow {
  final WorldCity city;
  const LocalCityRow(this.city);
}

class RemoteCityRow extends MergedCityRow {
  final RemoteCityResult result;
  const RemoteCityRow(this.result);
}

const int _maxRemoteRows = 8;

// Tunables: a remote row close enough to a local row is the same place;
// two remote rows next to each other are probably the same too. Distance
// gates keep the list short and free of obvious duplicates.
const double _localRemoteSuppressionKm = 10.0;
const double _remoteRemoteSuppressionKm = 1.0;

/// Combines local (bundled JSON) and remote (Nominatim) hits into one list.
///
/// Order: local first (in input order), then remote.
/// Dedupe: drop a remote within ~10 km of any same-country local row;
/// among remotes, dedupe by `placeId` then suppress hits within ~1 km of
/// an earlier-accepted remote.
List<MergedCityRow> mergeLocalAndRemote(
  List<WorldCity> local,
  List<RemoteCityResult> remote,
) {
  final rows = <MergedCityRow>[for (final c in local) LocalCityRow(c)];
  final seenPlaceIds = <String>{};
  final acceptedRemote = <RemoteCityResult>[];

  for (final r in remote) {
    if (!seenPlaceIds.add(r.placeId)) continue;
    final clashesLocal = local.any(
      (c) =>
          c.countryKey.toUpperCase() == r.countryCode &&
          _haversineKm(c.latitude, c.longitude, r.latitude, r.longitude) <
              _localRemoteSuppressionKm,
    );
    if (clashesLocal) continue;
    final clashesRemote = acceptedRemote.any(
      (a) =>
          _haversineKm(a.latitude, a.longitude, r.latitude, r.longitude) <
          _remoteRemoteSuppressionKm,
    );
    if (clashesRemote) continue;
    acceptedRemote.add(r);
    if (acceptedRemote.length >= _maxRemoteRows) break;
  }
  for (final r in acceptedRemote) {
    rows.add(RemoteCityRow(r));
  }
  return rows;
}

double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLng = _deg2rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_deg2rad(lat1)) *
          math.cos(_deg2rad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _deg2rad(double d) => d * (math.pi / 180.0);
