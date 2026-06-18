import 'package:flutter/material.dart';
import 'package:ghasaq/injection.dart';
import 'package:ghasaq/features/notifications/domain/usecases/get_notification_health.dart';

import 'mobile_settings_tile.dart';

/// Settings entry for notification health. Shows a warning state when any
/// permission is missing — this replaces the old sticky home-screen banner, so
/// a skipped/revoked permission is surfaced here instead of nagging from the
/// top of the home screen.
///
/// Reads the health snapshot through the notifications **domain** use-case
/// ([GetNotificationHealth]) — the allowed cross-feature boundary (§3) — and
/// refreshes whenever the user returns to the app.
class MobileNotificationHealthTile extends StatefulWidget {
  const MobileNotificationHealthTile({super.key});

  @override
  State<MobileNotificationHealthTile> createState() =>
      _MobileNotificationHealthTileState();
}

class _MobileNotificationHealthTileState
    extends State<MobileNotificationHealthTile>
    with WidgetsBindingObserver {
  bool _hasIssue = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final res = await getIt<GetNotificationHealth>()();
    res.fold((_) {}, (health) {
      if (mounted) setState(() => _hasIssue = !health.allGreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MobileSettingsTile(
      icon: _hasIssue
          ? Icons.warning_amber_rounded
          : Icons.health_and_safety_outlined,
      title: 'صحة الإشعارات',
      subtitle: _hasIssue
          ? 'إشعارات الأذان قد لا تصل — اضغط للمعالجة'
          : 'تشخيص ومعالجة مشاكل وصول الإشعارات',
      onTap: () => Navigator.of(context).pushNamed('/notification_health'),
    );
  }
}
