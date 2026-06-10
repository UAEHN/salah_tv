import 'entities/adhkar_session.dart';
import 'entities/dhikr.dart';

/// Read-only catalog of the morning/evening adhkar (text + repeat count + local
/// audio asset) played by the TV session-adhkar takeover. Separate from
/// [IAdhkarTextRepository] (silent reader/after-prayer content) because these
/// entries carry an [Dhikr.audioUrl] for per-dhikr playback.
abstract class ISessionAdhkarRepository {
  List<Dhikr> forSession(AdhkarSession session);
}
