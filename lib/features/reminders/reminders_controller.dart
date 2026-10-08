import 'package:flutter/foundation.dart';

import '../../core/models/reminder.dart';
import 'services/reminder_repository.dart';
import 'services/reminder_scheduler.dart';

class RemindersController extends ChangeNotifier {
  RemindersController(this._repo, this._scheduler);

  final ReminderRepository _repo;
  final ReminderScheduler _scheduler;
  List<Reminder> _items = [];

  List<Reminder> get items => List.unmodifiable(_items);

  Future<void> load() async {
    _items = _repo.load();
    _sort();
    notifyListeners();
    await _repo.save(_items);
    await resync();
  }

  /// Re-registers all alarms (e.g. after exact-alarm access was granted).
  Future<String?> resync() => _scheduler.sync(_items);

  /// All mutators update the list immediately, then persist + schedule.
  /// They return an error message or null.
  Future<String?> upsert(Reminder reminder) async {
    final error = reminder.validate();
    if (error != null) return error;
    final i = _items.indexWhere((r) => r.id == reminder.id);
    if (i < 0) {
      _items.add(reminder);
    } else {
      _items[i] = reminder;
    }
    _sort();
    notifyListeners();
    return _commit();
  }

  Future<String?> delete(String id) {
    _items.removeWhere((r) => r.id == id);
    notifyListeners();
    return _commit();
  }

  Future<String?> setEnabled(String id, bool enabled) {
    final i = _items.indexWhere((r) => r.id == id);
    if (i >= 0) _items[i] = _items[i].copyWith(enabled: enabled);
    notifyListeners();
    return _commit();
  }

  Future<String?> _commit() async {
    await _repo.save(_items);
    return _scheduler.sync(_items);
  }

  void _sort() => _items.sort((a, b) =>
      (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
}
