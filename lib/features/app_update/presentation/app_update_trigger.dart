import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/platform_config.dart';
import '../data/in_app_update_service.dart';
import '../domain/entities/update_status.dart';
import '../domain/i_app_update_repository.dart';
import '../domain/whats_new_changelog.dart';
import 'calm_moment_waiter.dart';
import 'remote_update_handler.dart';
import 'widgets/tv_whats_new_dialog.dart';
import 'widgets/whats_new_dialog.dart';

/// Runs Remote Config gating (forced/optional) → Play in-app update (only
/// if RC failed) → "What's New" dialog. On TV the optional/whats-new
/// dialogs wait for a calm prayer moment; on mobile they show immediately.
class AppUpdateTrigger extends StatefulWidget {
  const AppUpdateTrigger({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateTrigger> createState() => _AppUpdateTriggerState();
}

class _AppUpdateTriggerState extends State<AppUpdateTrigger> {
  static bool _sessionChecked = false;

  CalmMomentWaiter? _waiter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 15), _check);
    });
  }

  Future<void> _check() async {
    if (!mounted || _sessionChecked) return;
    _sessionChecked = true;

    final handler = RemoteUpdateHandler();
    final decision = await handler.evaluate();
    if (!mounted) return;

    if (decision?.status == UpdateStatus.forced) {
      await handler.showForced(context, decision!);
      return;
    }

    // Only fall back to Play's native update UI if Remote Config has no
    // answer — otherwise our dialog and Play's prompt would stack.
    if (decision == null) {
      GetIt.I<InAppUpdateService>().checkAndPrompt();
    }

    if (decision?.status == UpdateStatus.optional) {
      if (kIsTV) {
        // TV: defer to a calm prayer moment so the dialog never interrupts
        // an active adhan/iqama cycle on the always-on display.
        _waiter = CalmMomentWaiter(
          context: context,
          isStillActive: () => mounted,
          onCalm: () => handler.showOptional(context, decision!),
        )..start();
      } else {
        // Mobile: show immediately — there's no always-on cycle to disturb.
        handler.showOptional(context, decision!);
      }
      return;
    }

    final changelog = kIsTV ? kTvChangelog : kCurrentChangelog;
    if (changelog.isEmpty) return;

    final repo = GetIt.I<IAppUpdateRepository>();
    if (!await _shouldShowChangelog(repo)) return;
    if (!mounted) return;

    if (kIsTV) {
      _waiter = CalmMomentWaiter(
        context: context,
        isStillActive: () => mounted,
        onCalm: () => _showTvWhatsNew(repo),
      )..start();
    } else {
      _showMobileWhatsNew(repo, changelog);
    }
  }

  Future<bool> _shouldShowChangelog(IAppUpdateRepository repo) async {
    final isSeen = await repo.isCurrentVersionSeen();
    if (!kDebugMode && isSeen) return false;

    // Skip "What's New" for installs younger than 12 h — every screen is
    // already new to them. Mark the version seen so it never appears.
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchMs = prefs.getInt('rating_first_launch_ms');
    if (firstLaunchMs != null) {
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(firstLaunchMs),
      );
      if (age.inHours < 12) {
        await repo.markCurrentVersionSeen();
        if (!kDebugMode) return false;
      }
    }
    return true;
  }

  Future<void> _showTvWhatsNew(IAppUpdateRepository repo) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TvWhatsNewDialog(
        changelog: kTvChangelog,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
    repo.markCurrentVersionSeen();
  }

  Future<void> _showMobileWhatsNew(
    IAppUpdateRepository repo,
    List<String> changelog,
  ) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WhatsNewDialog(
        changelog: changelog,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
    repo.markCurrentVersionSeen();
  }

  @override
  void dispose() {
    _waiter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
