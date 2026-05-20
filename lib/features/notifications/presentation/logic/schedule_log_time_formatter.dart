/// Formats a [DateTime] for the schedule log row. Pulled out of the widget
/// per CLAUDE.md §3 (no time math in widgets) so the rule is testable in
/// isolation.
class ScheduleLogTimeFormatter {
  const ScheduleLogTimeFormatter();

  String format(DateTime fired, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final isToday = reference.year == fired.year &&
        reference.month == fired.month &&
        reference.day == fired.day;
    final hh = fired.hour.toString().padLeft(2, '0');
    final mm = fired.minute.toString().padLeft(2, '0');
    return isToday ? 'اليوم $hh:$mm' : '${fired.day}/${fired.month} $hh:$mm';
  }
}
