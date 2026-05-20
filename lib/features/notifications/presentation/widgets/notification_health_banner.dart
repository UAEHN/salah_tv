import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection.dart';
import '../cubit/notification_health_cubit.dart';
import '../cubit/notification_health_state.dart';
import '../screens/notification_health_screen.dart';

/// Sticky warning banner shown above the home shell when any notification
/// permission has been revoked since the user finished onboarding. Tapping
/// it opens the full health screen.
///
/// Uses a single shared [NotificationHealthCubit] so the banner reflects
/// any change the user makes from the health screen without an extra read.
class NotificationHealthBanner extends StatelessWidget {
  final Widget child;
  const NotificationHealthBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationHealthCubit>(
      create: (_) => getIt<NotificationHealthCubit>()..refresh(),
      child: _Body(child: child),
    );
  }
}

class _Body extends StatefulWidget {
  final Widget child;
  const _Body({required this.child});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationHealthCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationHealthCubit, NotificationHealthState>(
      builder: (context, state) {
        final showBanner = !state.isLoading && !state.health.allGreen;
        return Column(
          children: [
            if (showBanner) _Banner(),
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange.shade100,
      child: InkWell(
        onTap: () => _openHealth(context),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'بعض إعدادات الإشعارات تحتاج مراجعة لضمان وصول الأذان',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openHealth(BuildContext context) {
    final cubit = context.read<NotificationHealthCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<NotificationHealthCubit>.value(
          value: cubit,
          child: const NotificationHealthScreen(),
        ),
      ),
    );
  }
}
