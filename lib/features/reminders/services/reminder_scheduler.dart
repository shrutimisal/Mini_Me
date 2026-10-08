import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/constants/native_channel.dart';
import '../../../core/models/reminder.dart';
import '../../../core/platform/native_bridge.dart';

/// Pushes reminders to Android, which owns the actual alarms.
class ReminderScheduler {
  ReminderScheduler(this._bridge);

  final NativeBridge _bridge;

  /// Returns a user-facing error message, or null on success.
  Future<String?> sync(List<Reminder> reminders) async {
    try {
      await _bridge.call<int>(NativeChannel.syncReminders, {
        'json': jsonEncode(reminders.map((r) => r.toJson()).toList()),
      });
      return null;
    } on PlatformException catch (e) {
      return 'Could not schedule reminders: ${e.message ?? e.code}';
    } on MissingPluginException {
      return null;
    }
  }
}
