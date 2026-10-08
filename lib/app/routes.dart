import 'package:flutter/material.dart';

import '../core/models/reminder.dart';
import '../features/home/home_screen.dart';
import '../features/reminders/screens/reminder_edit_screen.dart';
import '../features/settings/settings_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const editReminder = '/reminder';
  static const settings = '/settings';

  static Route<dynamic> generate(RouteSettings route) {
    switch (route.name) {
      case editReminder:
        return MaterialPageRoute<void>(
          settings: route,
          builder: (_) => ReminderEditScreen(initial: route.arguments as Reminder?),
        );
      case settings:
        return MaterialPageRoute<void>(settings: route, builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute<void>(settings: route, builder: (_) => const HomeScreen());
    }
  }
}
