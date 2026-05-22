import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'notification_onboarding_cubit.dart';
import 'notification_onboarding_state.dart';
import 'widgets/notification_onboarding_background.dart';
import 'widgets/onboarding_action_bar.dart';
import 'widgets/onboarding_header.dart';
import 'widgets/permission_cards_list.dart';

/// Mobile-only "first run" notification setup. Calm dark layout with a
/// single warm radial glow — no animated stars, no mock notification.
/// Gates "متابعة" on the mandatory permission and lets the user fire a
/// real test notification before leaving the screen.
class NotificationOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const NotificationOnboardingScreen({super.key, required this.onComplete});

  @override
  State<NotificationOnboardingScreen> createState() =>
      _NotificationOnboardingScreenState();
}

class _NotificationOnboardingScreenState
    extends State<NotificationOnboardingScreen> with WidgetsBindingObserver {
  int _lastGrantedCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<NotificationOnboardingCubit>().start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationOnboardingCubit>().refreshHealth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04060D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const NotificationOnboardingBackground(),
          SafeArea(
            child: BlocConsumer<NotificationOnboardingCubit,
                NotificationOnboardingState>(
              listenWhen: (p, c) => p.coreGrantedCount != c.coreGrantedCount,
              listener: _onGrantedCountChanged,
              builder: (context, state) => state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _Body(state: state, onDone: _markDoneAndExit),
            ),
          ),
        ],
      ),
    );
  }

  void _onGrantedCountChanged(
    BuildContext context,
    NotificationOnboardingState state,
  ) {
    if (state.coreGrantedCount > _lastGrantedCount) {
      HapticFeedback.mediumImpact();
    }
    _lastGrantedCount = state.coreGrantedCount;
  }

  Future<void> _markDoneAndExit() async {
    await context.read<NotificationOnboardingCubit>().markDone();
    widget.onComplete();
  }
}

class _Body extends StatelessWidget {
  final NotificationOnboardingState state;
  final VoidCallback onDone;
  const _Body({required this.state, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationOnboardingCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingHeader(
            granted: state.coreGrantedCount,
            total: state.coreTotalCount,
          ),
          const SizedBox(height: 28),
          Expanded(child: PermissionCardsList(state: state, cubit: cubit)),
          const SizedBox(height: 12),
          OnboardingActionBar(
            canContinue: state.canContinue,
            canTest: state.health.postNotifications,
            isTesting: state.isTesting,
            onTest: () => _onTest(context, cubit),
            onContinue: onDone,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Future<void> _onTest(
    BuildContext context,
    NotificationOnboardingCubit cubit,
  ) async {
    await cubit.runTest();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيصلك إشعار تجريبي خلال 15 ثانية'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
