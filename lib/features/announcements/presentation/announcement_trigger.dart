import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/platform_config.dart';
import '../../app_update/domain/i_app_version_info_port.dart';
import '../../app_update/presentation/calm_moment_waiter.dart';
import '../domain/entities/announcement.dart';
import '../domain/i_announcement_repository.dart';
import 'widgets/mobile_announcement_dialog.dart';
import 'widgets/tv_announcement_dialog.dart';

/// Reads the active announcement from Firestore once per session and shows
/// it if the user hasn't already dismissed *that* id. On TV, the dialog
/// waits for a calm prayer moment so it never interrupts adhan/iqama; on
/// mobile it appears immediately after first frame.
class AnnouncementTrigger extends StatefulWidget {
  const AnnouncementTrigger({super.key, required this.child});

  final Widget child;

  @override
  State<AnnouncementTrigger> createState() => _AnnouncementTriggerState();
}

class _AnnouncementTriggerState extends State<AnnouncementTrigger> {
  static bool _sessionChecked = false;

  CalmMomentWaiter? _waiter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Debug builds skip the 25s stagger so testers see the dialog
      // immediately. Production keeps the delay so version dialogs always
      // win when both fire — users shouldn't see two dialogs stacked.
      final delay = kDebugMode
          ? const Duration(seconds: 2)
          : const Duration(seconds: 25);
      Future.delayed(delay, _check);
    });
  }

  Future<void> _check() async {
    if (!mounted || _sessionChecked) return;
    _sessionChecked = true;

    final repo = GetIt.I<IAnnouncementRepository>();
    final result = await repo.fetchActive();
    final announcement = result.fold((_) => null, (a) => a);

    if (kDebugMode) {
      debugPrint(
        '[AnnouncementTrigger] fetched=${announcement?.id ?? 'null'} '
        'displayable=${announcement?.isDisplayable ?? false}',
      );
    }

    if (announcement == null || !announcement.isDisplayable) return;

    // Version targeting: skip if the installed build falls outside the
    // [min..max] window declared in Firestore. Both 0 → all users.
    final build = await GetIt.I<IAppVersionInfoPort>().currentBuildNumber();
    if (!announcement.matchesVersion(build)) {
      if (kDebugMode) {
        debugPrint(
          '[AnnouncementTrigger] version $build outside '
          '[${announcement.minVersionCode}..${announcement.maxVersionCode}] '
          '— skipping',
        );
      }
      return;
    }

    // Debug builds bypass the "seen" cache so testers can repeat the dialog
    // by simply hot-restarting — no need to clear app data each time.
    final alreadySeen = !kDebugMode && await repo.hasSeen(announcement.id);
    if (alreadySeen) return;
    if (!mounted) return;

    if (kIsTV) {
      _waiter = CalmMomentWaiter(
        context: context,
        isStillActive: () => mounted,
        onCalm: () => _showTv(repo, announcement),
      )..start();
    } else {
      _showMobile(repo, announcement);
    }
  }

  Future<void> _showTv(
    IAnnouncementRepository repo,
    Announcement a,
  ) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TvAnnouncementDialog(
        announcement: a,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
    repo.markSeen(a.id);
  }

  Future<void> _showMobile(
    IAnnouncementRepository repo,
    Announcement a,
  ) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MobileAnnouncementDialog(
        announcement: a,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
    repo.markSeen(a.id);
  }

  @override
  void dispose() {
    _waiter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
