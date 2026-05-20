import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../domain/i_notification_onboarding_flag_port.dart';
import '../widgets/notification_health_banner.dart';
import 'notification_onboarding_cubit.dart';
import 'notification_onboarding_screen.dart';

/// Gate that decides between the notification onboarding flow and the real
/// home content on every mobile launch.
///
/// Reads [SettingsProvider] via `context.read` (cross-feature widget-tree
/// access is permitted by `CLAUDE.md §3` and is established practice across
/// adhkar/feedback/etc.). Wraps it in a private adapter so every layer
/// downstream of the gate (cubit, screen) sees only the
/// notifications-domain port.
class NotificationOnboardingGate extends StatefulWidget {
  final Widget child;
  const NotificationOnboardingGate({super.key, required this.child});

  @override
  State<NotificationOnboardingGate> createState() =>
      _NotificationOnboardingGateState();
}

class _NotificationOnboardingGateState
    extends State<NotificationOnboardingGate> {
  INotificationOnboardingFlagPort? _flag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_flag != null) return;
    final adapter = _SettingsFlagAdapter(context.read<SettingsProvider>());
    adapter.addListener(_onChanged);
    _flag = adapter;
  }

  @override
  void dispose() {
    _flag?.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final flag = _flag;
    if (flag == null) return const SizedBox.shrink();
    if (flag.isOnboardingDone) {
      return NotificationHealthBanner(child: widget.child);
    }
    return BlocProvider<NotificationOnboardingCubit>(
      create: (_) => getIt<NotificationOnboardingCubit>(param1: flag),
      child: NotificationOnboardingScreen(onComplete: flag.markDone),
    );
  }
}

/// Bridges [SettingsProvider] to the notifications-domain flag port.
/// Inlined here (rather than a standalone class in settings/data) so the
/// notifications feature carries no cross-feature data imports.
class _SettingsFlagAdapter implements INotificationOnboardingFlagPort {
  final SettingsProvider _provider;
  _SettingsFlagAdapter(this._provider);

  @override
  bool get isOnboardingDone => _provider.settings.isNotificationOnboardingDone;

  @override
  void addListener(void Function() listener) =>
      _provider.addListener(listener);

  @override
  void removeListener(void Function() listener) =>
      _provider.removeListener(listener);

  @override
  Future<void> markDone() => _provider.markNotificationOnboardingDone();
}
