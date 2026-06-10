import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/notification_health_cubit.dart';
import '../cubit/notification_health_state.dart';
import '../widgets/health_permissions_section.dart';
import '../widgets/schedule_log_list.dart';

/// Diagnostic screen for the native notification engine. Aggregates the
/// permission gates, OEM-specific guidance, and the recent firing log so
/// users can self-diagnose reliability issues.
class NotificationHealthScreen extends StatefulWidget {
  const NotificationHealthScreen({super.key});

  @override
  State<NotificationHealthScreen> createState() =>
      _NotificationHealthScreenState();
}

class _NotificationHealthScreenState extends State<NotificationHealthScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationHealthCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صحة الإشعارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<NotificationHealthCubit>().refresh(),
          ),
        ],
      ),
      body: BlocBuilder<NotificationHealthCubit, NotificationHealthState>(
        builder: (context, state) {
          if (state.isLoading && state.health.scheduleLog.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationHealthCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                HealthPermissionsSection(state: state),
                const SizedBox(height: 12),
                _TestButton(isPending: state.isTestPending),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'آخر الإشعارات المُطلقة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ScheduleLogList(entries: state.health.scheduleLog),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final bool isPending;
  const _TestButton({required this.isPending});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: isPending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.notifications_active),
        label: Text(
          isPending ? 'سيصل الإشعار خلال 15 ثانية...' : 'اختبر الإشعارات الآن',
        ),
        onPressed: isPending ? null : () => _onPressed(context),
      ),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<NotificationHealthCubit>().runTest();
    messenger.showSnackBar(
      const SnackBar(content: Text('سيصل إشعار اختبار خلال 15 ثانية')),
    );
  }
}
