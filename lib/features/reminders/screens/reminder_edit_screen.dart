import 'package:flutter/material.dart';

import '../../../core/models/reminder.dart';
import '../../../core/services/app_services.dart';
import '../../../shared/helpers/snackbar.dart';

class ReminderEditScreen extends StatefulWidget {
  const ReminderEditScreen({super.key, this.initial});

  final Reminder? initial;

  @override
  State<ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends State<ReminderEditScreen> {
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _intervalChoices = [1, 2, 3, 4, 6, 8, 12];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _message;
  late TimeOfDay _time;
  late RepeatType _repeat;
  late Set<int> _days;
  late int _intervalHours;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _title = TextEditingController(text: r?.title ?? '');
    _message = TextEditingController(text: r?.message ?? '');
    _time = TimeOfDay(hour: r?.hour ?? 20, minute: r?.minute ?? 0);
    _repeat = r?.repeat ?? RepeatType.daily;
    _days = {...(r?.days ?? const {1, 2, 3, 4, 5, 6, 7})};
    _intervalHours = r?.intervalHours ?? 2;
    _enabled = r?.enabled ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_repeat == RepeatType.weekly && _days.isEmpty) {
      showMessage(context, 'Pick at least one day.');
      return;
    }
    final reminder = Reminder(
      id: widget.initial?.id ?? Reminder.newId(),
      title: _title.text.trim(),
      message: _message.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      repeat: _repeat,
      days: _days,
      intervalHours: _intervalHours,
      enabled: _enabled,
    );
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final error = await AppServices.instance.reminders.upsert(reminder);
    navigator.pop();
    if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _delete() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final error = await AppServices.instance.reminders.delete(widget.initial!.id);
    navigator.pop();
    if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reminder' : 'New Reminder'),
        actions: [
          if (isEditing)
            IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete', onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              maxLength: 40,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _message,
              maxLength: 140,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Message MiniMe will say',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a message.' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(_repeat == RepeatType.interval ? 'Starting at' : 'Time'),
              trailing: Text(_time.format(context), style: Theme.of(context).textTheme.titleLarge),
              onTap: _pickTime,
            ),
            const SizedBox(height: 8),
            SegmentedButton<RepeatType>(
              segments: const [
                ButtonSegment(value: RepeatType.daily, label: Text('Daily')),
                ButtonSegment(value: RepeatType.weekly, label: Text('Days')),
                ButtonSegment(value: RepeatType.interval, label: Text('Every N h')),
              ],
              selected: {_repeat},
              onSelectionChanged: (s) => setState(() => _repeat = s.first),
            ),
            const SizedBox(height: 12),
            if (_repeat == RepeatType.weekly)
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 1; i <= 7; i++)
                    FilterChip(
                      label: Text(_dayLabels[i - 1]),
                      selected: _days.contains(i),
                      onSelected: (on) => setState(() => on ? _days.add(i) : _days.remove(i)),
                    ),
                ],
              ),
            if (_repeat == RepeatType.interval)
              Wrap(
                spacing: 8,
                children: [
                  for (final h in _intervalChoices)
                    ChoiceChip(
                      label: Text('$h h'),
                      selected: _intervalHours == h,
                      onSelected: (_) => setState(() => _intervalHours = h),
                    ),
                ],
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enabled'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
