import 'package:flutter/material.dart';

import '../../domain/entities/schedule_log_entry.dart';
import '../logic/schedule_log_time_formatter.dart';

class ScheduleLogList extends StatelessWidget {
  final List<ScheduleLogEntry> entries;

  const ScheduleLogList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'لا توجد إشعارات مسجلة بعد. اضغط "اختبر الآن" للتحقق.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (_, i) => _LogTile(entry: entries[i]),
    );
  }
}

class _LogTile extends StatelessWidget {
  final ScheduleLogEntry entry;

  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = entry.success ? Colors.green : Colors.red;
    final icon = entry.success ? Icons.check : Icons.error_outline;
    final time = const ScheduleLogTimeFormatter().format(entry.firedAt);
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        '${entry.type}${entry.prayerKey != null ? ' · ${entry.prayerKey}' : ''}',
      ),
      subtitle: Text(
        entry.success ? time : '$time · ${entry.error ?? 'failed'}',
      ),
    );
  }
}
