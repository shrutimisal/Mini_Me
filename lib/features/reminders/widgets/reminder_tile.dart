import 'package:flutter/material.dart';

import '../../../core/models/reminder.dart';

const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String repeatSummary(Reminder r) {
  switch (r.repeat) {
    case RepeatType.daily:
      return 'Every day';
    case RepeatType.interval:
      return 'Every ${r.intervalHours} hour${r.intervalHours == 1 ? '' : 's'}';
    case RepeatType.weekly:
      final d = r.days;
      if (d.length == 7) return 'Every day';
      if (d.length == 5 && !d.contains(6) && !d.contains(7)) return 'Mon–Fri';
      final sorted = d.toList()..sort();
      return sorted.map((i) => _dayNames[i - 1]).join(', ');
  }
}

String emojiFor(String title) {
  final t = title.toLowerCase();
  if (t.contains('water') || t.contains('drink')) return '💧';
  if (t.contains('sleep') || t.contains('bed')) return '😴';
  if (t.contains('study') || t.contains('read')) return '📚';
  if (t.contains('walk') || t.contains('exercise') || t.contains('gym')) return '🏃';
  return '⏰';
}

class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onTap,
  });

  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute).format(context);
    return ListTile(
      leading: Text(emojiFor(reminder.title), style: const TextStyle(fontSize: 28)),
      title: Text(reminder.title),
      subtitle: Text('$time · ${repeatSummary(reminder)}'),
      trailing: Switch(value: reminder.enabled, onChanged: onToggle),
      onTap: onTap,
    );
  }
}
