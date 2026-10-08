import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/reminder.dart';

class ReminderRepository {
  ReminderRepository(this._prefs);

  static const _key = 'reminders_v1';
  final SharedPreferences _prefs;

  List<Reminder> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return _samples();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Reminder.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return []; // Corrupt data: start clean rather than crash.
    }
  }

  Future<void> save(List<Reminder> items) =>
      _prefs.setString(_key, jsonEncode(items.map((r) => r.toJson()).toList()));

  /// First-run examples. Disabled so nothing fires until the user opts in.
  List<Reminder> _samples() => [
        Reminder(
          id: Reminder.newId(),
          title: 'Drink Water',
          message: 'Hey! Time for a water break 💧',
          hour: 10,
          minute: 0,
          repeat: RepeatType.interval,
          intervalHours: 2,
          enabled: false,
        ),
        Reminder(
          id: '${Reminder.newId()}1',
          title: 'Sleep',
          message: 'Hey! It\'s time to sleep 😴',
          hour: 23,
          minute: 0,
          enabled: false,
        ),
      ];
}
