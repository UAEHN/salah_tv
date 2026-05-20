import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../onboarding/presentation/widgets/onboarding_background.dart';
import 'notification_onboarding_cubit.dart';
import 'notification_onboarding_state.dart';
import 'widgets/mock_adhan_notification_preview.dart';
import 'widgets/onboarding_action_bar.dart';
import 'widgets/onboarding_header.dart';
import 'widgets/onboarding_progress_chip.dart';
import 'widgets/permission_cards_list.dart';

/// Mobile-only "first run" notification setup. Visually consistent with the
/// main `OnboardingScreen` (dark gradient + animated stars), shows a mock
/// notification preview as a value hook, gates "متابعة" on the mandatory
/// permission, and lets the user fire a real test notification before
/// leaving the screen.
class NotificationOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const NotificationOnboardingScreen({super.key, required this.onComplete});

  @override
  State<NotificationOnboardingScreen> createState() =>
      _NotificationOnboardingScreenState();
}

class _NotificationOnboardingScreenState
    extends State<NotificationOnboardingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final AnimationController _bgController;
  int _lastGrantedCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    context.read<NotificationOnboardingCubit>().start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgController.dispose();
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
      backgroundColor: const Color(0xFF050A18),
      body: Stack(
        fit: StackFit.expand,
        children: [
          OnboardingBackground(starsAnimation: _bgController),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingHeader(
            trailing: OnboardingProgressChip(
              granted: state.coreGrantedCount,
              total: state.coreTotalCount,
            ),
          ),
          const SizedBox(height: 16),
          MockAdhanNotificationPreview(
            isAcknowledged: state.health.postNotifications,
          ),
          const SizedBox(height: 18),
          Expanded(child: PermissionCardsList(state: state, cubit: cubit)),
          const SizedBox(height: 4),
          OnboardingActionBar(
            canContinue: state.canContinue,
            canTest: state.health.postNotifications,
            isTesting: state.isTesting,
            onTest: () => _onTest(context, cubit),
            onContinue: onDone,
          ),
          const SizedBox(height: 6),
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
