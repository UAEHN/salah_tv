import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/platform_config.dart';
import '../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../prayer/presentation/bloc/prayer_state.dart';
import '../data/in_app_update_service.dart';
import '../domain/i_app_update_repository.dart';
import '../domain/whats_new_changelog.dart';
import 'widgets/tv_whats_new_dialog.dart';
import 'widgets/whats_new_dialog.dart';

/// Wraps [child] and — after the screen settles — does two things:
///   1. Asks Google Play if an update is available (native UI, fire-and-forget).
///   2. Shows "What's New" once per version if the user hasn't seen it yet.
///
/// **TV behaviour:** waits for a calm prayer moment (no active cycle,
/// ≥5 min until next prayer) before showing [TvWhatsNewDialog] — mirrors
/// the same guard used in [TvRatingTrigger].
///
/// **Mobile behaviour:** shows [WhatsNewDialog] after a 5-second delay.
class AppUpdateTrigger extends StatefulWidget {
  const AppUpdateTrigger({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateTrigger> createState() => _AppUpdateTriggerState();
}

class _AppUpdateTriggerState extends State<AppUpdateTrigger> {
  // Static: prevents double-show if widget is recreated in same session.
  static bool _sessionChecked = false;

  StreamSubscription<PrayerState>? _prayerSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // مدة الانتظار 15 ثانية (لكل من التطوير والإنتاج) كما طلبت للاختبار الواقعي
      Future.delayed(const Duration(seconds: 15), _check);
    });
  }

  Future<void> _check() async {
    if (!mounted || _sessionChecked) return;
    _sessionChecked = true;

    // Play update check — runs in background, shows native UI if update exists.
    GetIt.I<InAppUpdateService>().checkAndPrompt();

    final changelog = kIsTV ? kTvChangelog : kCurrentChangelog;
    if (changelog.isEmpty) return;

    final repo = GetIt.I<IAppUpdateRepository>();
    final isSeen = await repo.isCurrentVersionSeen();
    
    // في وضع التطوير، نتجاهل شرط الرؤية المسبقة لكي تظهر دائماً للاختبار
    if (!kDebugMode && isSeen) return;
    if (!mounted) return;

    // حماية إضافية: إذا كان هذا مستخدماً جديداً جداً (حمّل التطبيق للتو وانتهى من الأونبوردنج)،
    // لا يجب أن تظهر له شاشة "ما الجديد" لأن كل التطبيق جديد بالنسبة له.
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchMs = prefs.getInt('rating_first_launch_ms');
    if (firstLaunchMs != null) {
      final firstLaunch = DateTime.fromMillisecondsSinceEpoch(firstLaunchMs);
      // إذا كان عمر التثبيت أقل من 12 ساعة، نعتبره مستخدماً جديداً ونسجل الرؤية بصمت
      if (DateTime.now().difference(firstLaunch).inHours < 12) {
        await repo.markCurrentVersionSeen();
        if (!kDebugMode) return; // نتجاهل هذا المنع أيضاً في التطوير للاختبار
      }
    }

    if (kIsTV) {
      _waitForCalmMomentThenShow(repo);
    } else {
      _showMobileDialog(repo, changelog);
    }
  }

  // ─── TV: wait for calm prayer moment ──────────────────────────────────────

  void _waitForCalmMomentThenShow(IAppUpdateRepository repo) {
    if (!mounted) return;
    final bloc = context.read<PrayerBloc>();
    _onPrayerState(bloc.state, repo);
    _prayerSub = bloc.stream.listen((s) => _onPrayerState(s, repo));
  }

  void _onPrayerState(PrayerState state, IAppUpdateRepository repo) {
    if (!mounted) return;
    final isCalmMoment = !state.isCycleActive &&
        state.todayPrayers != null &&
        state.countdown.inMinutes >= 5;
    if (!isCalmMoment) return;

    _prayerSub?.cancel();
    _prayerSub = null;
    _showTvDialog(repo);
  }

  Future<void> _showTvDialog(IAppUpdateRepository repo) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TvWhatsNewDialog(
        changelog: kTvChangelog,
        onDismiss: () {
          Navigator.of(context).pop();
        },
      ),
    );
    repo.markCurrentVersionSeen();
  }

  // ─── Mobile: show after delay ─────────────────────────────────────────────

  Future<void> _showMobileDialog(
    IAppUpdateRepository repo,
    List<String> changelog,
  ) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WhatsNewDialog(
        changelog: changelog,
        onDismiss: () {
          Navigator.of(context).pop();
        },
      ),
    );
    repo.markCurrentVersionSeen();
  }

  @override
  void dispose() {
    _prayerSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
