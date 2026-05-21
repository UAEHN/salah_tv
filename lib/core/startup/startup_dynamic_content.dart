import 'package:flutter/foundation.dart';

import '../../features/today/data/islamic_occasions_repository_impl.dart';
import '../../features/today/domain/i_islamic_occasions_repository.dart';
import '../../injection.dart';

/// Fire-and-forget background refresh of the dynamic content layer.
///
/// Called after the rest of the startup pipeline has resolved so app boot is
/// never blocked by a flaky network. Each step is independently best-effort:
/// any failure inside [loadCatalog] is already caught by the repo (falls
/// back to cache → bundled asset), so this coordinator only needs to swallow
/// exceptions raised before that point (e.g. DI lookup miss).
Future<void> primeDynamicContent() async {
  try {
    final repo = getIt<IIslamicOccasionsRepository>();
    if (repo is IslamicOccasionsRepositoryImpl) {
      // Force a fresh fetch so a new manifest published since last launch
      // wins over the in-memory copy from a previous session.
      await repo.loadCatalog(forceRefresh: true);
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[DynamicContent] prime failed (non-fatal): $e');
    }
  }
}
